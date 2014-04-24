//
//  OTVVideoPlayerViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//


#import "OTVVideoPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"

#import "Show.h"
#import "OTVEpisode.h"
#import "OTVPart.h"

#import "CMVideoAds.h"
#import "CMPlayerViewController.h"

@interface OTVVideoPlayerViewController () <CMVideoAdsDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet UIToolbar *videoToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *partInfoBarButtonItem;
@property (strong, nonatomic) MPMoviePlayerController *movieController;


@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) CMVideoAds *videoAds;


-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers:(MPMoviePlayerController *)player;
-(void)removeMovieNotificationHandlers:(MPMoviePlayerController *)player;
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player;
- (void) movieDurationAvailableDidChange:(NSNotification*)notification;

@end

@implementation OTVVideoPlayerViewController {
    CGSize _size;
    CGFloat _widthOfCH7iFrame;
    OTVPart *_part;
    AVPlayerLayer *_layer;
    BOOL _isContent;

}

static NSString *cmPlayerSegue = @"CMPlayerSegue";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _widthOfCH7iFrame = 640;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
        
    }
    else
    {
        _size = CGSizeMake(320, 240);

    }
    
    [self initializeUI];
}

- (void)initializeUI
{
    _part = [self.otvEpisode.parts objectAtIndex:self.idx];
    self.navigationItem.title = self.otvEpisode.nameTh;
    OTVPart *otvPart = (OTVPart *)_part;
    
    self.partInfoBarButtonItem.title = otvPart.nameTh;
    
    [self enableOrDisableNextPreviousButton];
    
    self.titleLabel.text = self.otvEpisode.nameTh;
    self.detailTextView.text = self.otvEpisode.detail;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:otvPart.thumbnail]
                            placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.detailTextViewHeight.constant = [self textViewHeight:self.detailTextView];
}

- (CGFloat)textViewHeight:(UITextView *)textView
{
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
    CGRect usedRect = [textView.layoutManager
                       usedRectForTextContainer:textView.textContainer];
    return ceilf(usedRect.size.height) + 5;
}


#pragma mark - Video Operations

- (void)playCurrentVideo
{
    DLog(@"vastURL : %@", _part.vastURL);
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    self.videoAds = [[CMVideoAds alloc] initWithVastTagURL:_part.vastURL];
    self.videoAds.delegate = self;
}

- (BOOL)moveNextVideo
{
    if (_idx+1 < self.otvEpisode.parts.count) {
        _idx = _idx+1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
            
            _part = [self.otvEpisode.parts objectAtIndex:_idx];
            
            [self initializeUI];
        }
        
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)movePreviousVideo
{
    if (_idx >= 1) {
        _idx = _idx-1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
            [self initializeUI];
            
        } else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.movieController) {
        [self.movieController.view setFrame:CGRectMake(0, 0,
                                                       CGRectGetWidth(self.view.frame),
                                                       CGRectGetHeight(self.view.frame))];
    }
    [self.skipButton setNeedsUpdateConstraints];
    [self.view setNeedsUpdateConstraints];
}

- (void)didRequestVideoAds:(CMVideoAds *)videoAds success:(BOOL)success {
    [SVProgressHUD dismiss];
    DLog(@"%@", videoAds);
    DLog(@"mediaFile : %@", videoAds.mediaFile);
    DLog(@"streamURL : %@", _part.streamURL);
    
    NSString *movieFileURL = [NSString string];
    
    if (success && videoAds != nil && videoAds.mediaFile != nil) {
        _isContent = NO;
        movieFileURL = videoAds.mediaFile;
        if (!_isContent && self.videoAds) {
            [self.videoAds hitTrackingEvent:START];
            [self.videoAds hitTrackingEvent:FIRST_QUARTILE];
            [self.videoAds hitTrackingEvent:MIDPOINT];
            [self.videoAds hitTrackingEvent:THIRD_QUARTILE];
        }
    }
    else
    {
        _isContent = YES;
        movieFileURL = _part.streamURL;
    }
    
    [self playMovieStream:movieFileURL];
}


- (void)playMovieStream:(NSString *)movieFileURL
{
    
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    
    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:movieFileURL]];
    [self installMovieNotificationObservers:self.movieController];
    
    self.movieController.movieSourceType = movieSourceType;
    [self.movieController prepareToPlay];
    [self.movieController play];
    
    if (_isContent)
    {
        self.movieController.controlStyle = MPMovieControlStyleFullscreen;
    }
    else
    {
        self.movieController.controlStyle = MPMovieControlStyleFullscreen;
    }
    
    [self.view addSubview:self.movieController.view];
    [self.movieController setFullscreen:YES animated:NO];
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
    //	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
        //        [self.overlayController setLoadStateDisplayString:@"n/a"];
        //
        //        [overlayController setLoadStateDisplayString:@"unknown"];
	}
    //
    //	/* The buffer has enough data that playback can begin, but it
    //	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
        //        [overlayController setLoadStateDisplayString:@"playable"];
	}
    //
    //	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
//        self.backgroundView.hidden = YES;
        
        // Add an overlay view on top of the movie view
        //        [self addOverlayView];
        //
        //        [overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
    //
    //	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
//        self.backgroundView.hidden = NO;
        //        [overlayController setLoadStateDisplayString:@"stalled"];
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        DLog(@"%@", @"stopped");
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        DLog(@"%@", @"playing");
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        DLog(@"%@", @"paused");
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        DLog(@"%@", @"interrupted");
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    //    [self addOverlayView];
}

- (void) movieDurationAvailableDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    DLog(@"%f", player.currentPlaybackTime);
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers:(MPMoviePlayerController *)player
{
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieDurationAvailableDidChange:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:player];
    
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers:(MPMoviePlayerController *)player
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player
{
    [self removeMovieNotificationHandlers:player];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:cmPlayerSegue]) {
        NSURL *videoURL = [NSURL URLWithString:(NSString *)sender];
        CMPlayerViewController *cmPlayerViewController = segue.destinationViewController;
        [cmPlayerViewController playMovieStream:videoURL];
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    if (!_isContent && self.videoAds) {
        [self.videoAds hitTrackingEvent:COMPLETE];
    }
    
    MPMoviePlayerController *player = [notification object];

    [self removeMovieNotificationHandlers:player];
    [self.movieController.view removeFromSuperview];
    
    if (_isContent) {
        _isContent = NO;
        if ([self moveNextVideo]) {
            [SVProgressHUD showWithStatus:@"Move Next Video"];
            [self playCurrentVideo];
        }
        
    } else {
        _isContent = YES;
        [self playMovieStream:_part.streamURL];
    }
}

- (void)didRequestVideoAds:(CMVideoAds *)videoAds error:(NSError *)error {
    [SVProgressHUD dismiss];
    if ([self.show.otvApiName isEqualToString:kOTV_CH7]) {
        //iFrame
        [self openWithIFRAME:_part.streamURL];
    } else {
        [self openWithVideoUrl:_part.streamURL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) openWithVideoUrl:(NSString *)videoUrl {
    // HTML to embed YouTube video
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><video poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" controls autoplay>\
    <source src=\"%@\" />\
    </video></div></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      [_part thumbnail],
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
}

- (void) openWithIFRAME:(NSString *)iframeText {
    if (self.webView == nil) {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [self.view addSubview:self.webView];
    }
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            %@</body></html>", _widthOfCH7iFrame, [self htmlEntityDecode:iframeText]];
    
    
    [self.webView loadHTMLString:htmlString
                         baseURL:nil];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
}

-(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

#pragma mark - UI Action

- (IBAction)playButton:(id)sender {
    [self playCurrentVideo];
}

- (IBAction)previousButtonTouched:(id)sender {
    [self movePreviousVideo];
}

- (IBAction)nextButtonTouched:(id)sender {
    [self moveNextVideo];
}

/** EnableOrDisableNextPreviousButton **/
- (void)enableOrDisableNextPreviousButton
{
    if ( _idx==0 )
    {
        self.previousBarButtonItem.enabled = NO;
    }else{
        self.previousBarButtonItem.enabled = YES;
    }
    
    if ( _idx == self.otvEpisode.parts.count - 1 ) {
        self.nextBarButtonItem.enabled = NO;
    }else{
        self.nextBarButtonItem.enabled = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
