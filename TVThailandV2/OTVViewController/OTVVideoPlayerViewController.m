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
#import "HTMLParser.h"

#import "Show.h"
#import "OTVEpisode.h"
#import "OTVPart.h"

#import "CMVideoAds.h"
#import "DVInlineVideoAd.h"
#import "WebIframeViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface OTVVideoPlayerViewController () <CMVideoAdsDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeight;

@property (weak, nonatomic) IBOutlet UIToolbar *videoToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *partInfoBarButtonItem;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) MPMoviePlayerController *movieController;

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
//    CGSize _size;
    CGFloat _widthOfCH7iFrame;
    OTVPart *_part;
    AVPlayerLayer *_layer;
    BOOL _isContent;

}

static NSString *cmPlayerSegue = @"CMPlayerSegue";
static NSString *webIFrameSegue = @"WebIFrameSegue";

static NSString *kCodeStream = @"1000";
static NSString *kCodeAds = @"1001";
static NSString *kCodeIframe = @"1002";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _widthOfCH7iFrame = 640;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        _size = CGSizeMake(768, 460);
       _widthOfCH7iFrame = 480;
    }
    else
    {
       _widthOfCH7iFrame = 280;
//        _size = CGSizeMake(320, 240);

    }
    
    [self initializeUI];
    [self sendTracker];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
}

- (void)sendTracker
{
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:_part.nameTh
                                                       forKey:[GAIFields customDimensionForIndex:3]] build]];
}
- (void)initializeUI
{
    _part = [self.otvEpisode.parts objectAtIndex:self.idx];
   
    OTVPart *otvPart = (OTVPart *)_part;
    
    self.partInfoBarButtonItem.title = otvPart.nameTh;
    
    [self enableOrDisableNextPreviousButton];
    
     self.navigationItem.title = self.otvEpisode.nameTh;
    self.titleLabel.text = self.otvEpisode.nameTh;
    self.detailTextView.text = self.otvEpisode.detail;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:otvPart.thumbnail]
                            placeholderImage:[UIImage imageNamed:@"otv_icon"]];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.detailTextViewHeight.constant = [self textViewHeight:self.detailTextView];
}

- (CGFloat)textViewHeight:(UITextView *)textView
{
    if ([textView respondsToSelector:@selector(layoutManager)])
    {
        [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
        CGRect usedRect = [textView.layoutManager
                           usedRectForTextContainer:textView.textContainer];
        return ceilf(usedRect.size.height) + 10;
    }
    
    return 400;
}


#pragma mark - Video Operations

- (void)playCurrentVideo
{
    self.webView.hidden = YES;
    
    DLog(@"vastURL : %@", _part.vastURL);
    
    if (_isContent) {
        if ([_part.mediaCode isEqualToString:kCodeStream])
        {
            [self playMovieStream:[NSURL URLWithString:_part.streamURL]];
            
            id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                                 trackingId:kOTVTracker];
            [tracker2 set:kGAIScreenName
                    value:@"OTVEpisode"];
            [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:_part.streamURL
                                                               forKey:[GAIFields customDimensionForIndex:6]] build]];
        }
        else if ([_part.mediaCode isEqualToString:kCodeIframe])
        {
            [self openWithIFRAME:_part.streamURL];
        }
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Loading..."];
        self.videoAds = [[CMVideoAds alloc] initWithVastTagURL:_part.vastURL];
        self.videoAds.delegate = self;
        
    }
}

- (BOOL)moveNextVideo
{
    self.webView.hidden = YES;
    _isContent = NO;
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
    self.webView.hidden = YES;
    _isContent = NO;
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
    [self.view setNeedsUpdateConstraints];
}


#pragma mark - Delegate VideoAds

- (void)didRequestVideoAds:(CMVideoAds *)videoAds success:(BOOL)success {
    [SVProgressHUD dismiss];
//    DLog(@"%@", videoAds);
//    DLog(@"mediaFile : %@", [videoAds.ad.mediaFileURL absoluteString]);
//    DLog(@"streamURL : %@", _part.streamURL);
    
    if (success) {
        [self.videoAds hitTrackingEvent:START];
        [self.videoAds hitTrackingEvent:FIRST_QUARTILE];
        [self.videoAds hitTrackingEvent:MIDPOINT];
        [self.videoAds hitTrackingEvent:THIRD_QUARTILE];
        
        id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                             trackingId:kOTVTracker];
        [tracker2 set:kGAIScreenName
                value:@"Player"];
        [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:videoAds.URL
                                                           forKey:[GAIFields customDimensionForIndex:4]] build]];
        
        [self playMovieStream:videoAds.ad.mediaFileURL];
    }
    else
    {
        _isContent = !_isContent;
        [self playCurrentVideo];
    }
}

- (void)didRequestVideoAds:(CMVideoAds *)videoAds error:(NSError *)error {
    [SVProgressHUD dismiss];
    
    _isContent = !_isContent;
    [self playCurrentVideo];
}


- (void)playMovieStream:(NSURL *)movieFileURL
{
    
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    
    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieFileURL];
    [self installMovieNotificationObservers:self.movieController];
    
    self.movieController.allowsAirPlay = YES;
    self.movieController.movieSourceType = movieSourceType;
    [self.movieController prepareToPlay];
    [self.movieController play];
    
    if (_isContent)
    {
        self.movieController.controlStyle = MPMovieControlStyleFullscreen;
    }
    else
    {
        self.movieController.controlStyle = MPMovieControlStyleNone;
        
        double delayInSeconds = 7.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            self.movieController.controlStyle = MPMovieControlStyleFullscreen;
        });
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
    if ([segue.identifier isEqualToString:webIFrameSegue]) {
        OTVPart *otvPart = (OTVPart *)sender;
        WebIFrameViewController *webIframeViewController = segue.destinationViewController;
        webIframeViewController.part = otvPart;
    }
    
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    if (!_isContent && self.videoAds) {
        [self.videoAds hitTrackingEvent:COMPLETE];
        id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                             trackingId:kOTVTracker];
        [tracker2 set:kGAIScreenName
                value:@"Player"];
        [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:self.videoAds.URL
                                                           forKey:[GAIFields customDimensionForIndex:5]] build]];
    }
    
    MPMoviePlayerController *player = [notification object];

    [self removeMovieNotificationHandlers:player];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
    
    
    _isContent = !_isContent;
    
    
    if (_isContent)
    {
        [self playCurrentVideo];
    }
    else
    {
        if ([self moveNextVideo])
        {
                [self playCurrentVideo];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) openWithIFRAME:(NSString *)iframeText {
//    [self performSegueWithIdentifier:webIFrameSegue sender:_part];
    
    self.webView.hidden = NO;
    [SVProgressHUD dismiss];
    
    
    NSString *iframeHtml= [self htmlEntityDecode:iframeText];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            %@</body></html>", _widthOfCH7iFrame, iframeHtml];
    
    
    [self.webView loadHTMLString:htmlString
                         baseURL:nil];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setScrollEnabled:NO];
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:iframeHtml error:&error];
    
    if (error)
    {
        DLog(@"Error: %@", error);
    }
    else
    {
        HTMLNode *bodyNode = [parser body];
        NSArray *sourceNodes = [bodyNode findChildTags:@"iframe"];
        for (HTMLNode *sourceNode in sourceNodes)
        {
            NSString *iframeURL = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            if(iframeURL)
            {
                id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                                     trackingId:kOTVTracker];
                [tracker2 set:kGAIScreenName
                        value:@"OTVEpisode"];
                [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:iframeURL
                                                                   forKey:[GAIFields customDimensionForIndex:6]] build]];
            }
            
        }

    }
    
    
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
    _isContent = NO;
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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                
                if(self.movieController.playbackState == MPMoviePlaybackStatePlaying)
                {
                    [self.movieController pause];
                }
                else
                {
                    [self.movieController play];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self.movieController setCurrentPlaybackTime:self.movieController.currentPlaybackTime + 10];
                break;
            default:
                break;
        }
    }
}

@end
