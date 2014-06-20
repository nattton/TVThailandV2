//
//  YouTubeViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "PlayerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import "HTMLParser.h"

#import "CMVideoAds.h"
#import "DVInlineVideoAd.h"
#import "WebIframeViewController.h"

#import "Show.h"
#import "Episode.h"
#import "OTVEpisode.h"
#import "OTVPart.h"

#import "VideoPartTableViewCell.h"
#import "OTVEpisodePartViewController.h"

@interface PlayerViewController () <UITableViewDataSource, UITableViewDelegate, CMVideoAdsDelegate>

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTopSpace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopSpace;

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

@implementation PlayerViewController {
    NSString *_videoId;
    CGSize _size;
    BOOL _isContent;
    OTVPart *_part;
    CGFloat _widthOfCH7iFrame;
    AVPlayerLayer *_layer;
}

#pragma mark - Staic Variable
static int SECTION_VIDEO = 0;
static int SECTION_RELATED = 1;
static NSString *videoPartCell = @"videoPartCell";
static NSString *kCodeStream = @"1000";
static NSString *kCodeAds = @"1001";
static NSString *kCodeIframe = @"1002";

#pragma mark - ALL
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLableContainner];
    
    if (self.show) {
        [self initVideoPlayer:_idx sectionOfVideo:0];
        
        [self startOTV];
    }

    [self setUpOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    
}

- (void)setUpOrientation:(UIInterfaceOrientation)orientation {
    
     _widthOfCH7iFrame = 640;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _widthOfCH7iFrame = 480;
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            self.videoContainerWidth.constant = 700.0f;
            self.videoContainerHeight.constant = 390.0f;
            self.tableViewLeftSpace.constant = 0.0f;
            self.tableViewTopSpace.constant = self.videoContainerWidth.constant + 15.f;
        } else {
            self.videoContainerWidth.constant = 768.0f;
            self.videoContainerHeight.constant = 470.0f;
            self.tableViewLeftSpace.constant = 608.0f;
            self.tableViewTopSpace.constant = 15.f;
        }
    } else {
        _widthOfCH7iFrame = 280;
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            [self.videoPlayerViewController.moviePlayer setFullscreen:YES animated:YES];
            self.videoContainerHeight.constant = 320.0f;
        } else {
            [self.videoPlayerViewController.moviePlayer setFullscreen:NO animated:YES];
            self.videoContainerHeight.constant = 236.0f;
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setUpOrientation:toInterfaceOrientation];
    [self.tableOfVideoPart reloadData];
}


- (void) initLableContainner {
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(700.0f, 390.0f);
        
    }
    else
    {
        _size = CGSizeMake(320, 240);
    
    }
    
    
    self.titleContainerView.layer.masksToBounds = NO;
    self.titleContainerView.layer.cornerRadius = 2;
    self.titleContainerView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.titleContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.titleContainerView.layer.shadowRadius = 0.6;
    self.titleContainerView.layer.shadowOpacity = 0.6;
    
    self.titleContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.titleContainerView.bounds].CGPath;
    
    self.tableOfVideoPart.separatorColor = [UIColor clearColor];
    [self.tableOfVideoPart setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.tableOfVideoPart setSeparatorColor:[UIColor colorWithRed: 240/255.0 green:240/255.0 blue:240/255.0 alpha:0.7]];
    


}

#pragma mark - Init Video

- (void) initVideoPlayer:(NSInteger)row sectionOfVideo:(long)section {
    
    self.showNameLabel.text = self.show.title;
    
    if (self.show.isOTV) {
        
        [self initOtvVideoPlayer:row sectionOfVideo:section];
    }
    else {
        [self initTvThVideoPlayer:row sectionOfVideo:section];
    }
    
    [self.tableOfVideoPart reloadData];
    
    [self setSelectedPositionOfVideoPartAtRow:row section:section];
    
}

- (void) initTvThVideoPlayer:(NSInteger)row sectionOfVideo:(long)section {
    /* episode section */
    if (section == SECTION_VIDEO) {
        [self openWithVideo:self.episode Row:row];
    }
    /* other episode section */
    else if (section == SECTION_RELATED) {
        [self openWithVideo:self.otherEpisode Row:row];
    }
}

- (void) openWithVideo:(Episode *)episode Row:(NSInteger)row {
    if (episode) {
        if ([episode.videos count] == 1||[episode.videos count] == 0) {
            self.partNameLabel.hidden = YES;
        } else {
            self.partNameLabel.hidden = NO;
        }
        
        _videoId = episode.videos[row];
        self.episodeNameLabel.text = episode.titleDisplay;
        self.viewCountLabel.text = episode.viewCount;
        self.partNameLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)row + 1, (long)episode.videos.count ];
        
        if ([episode.srcType isEqualToString:@"0"]) {
            self.webView.hidden = YES;
            [self openWithYoutubePlayerEmbed:_videoId];
        }
        else if ([episode.srcType isEqualToString:@"1"]) {
            self.webView.hidden = NO;
            [self openWithDailymotionEmbed];
        }
        else if ([episode.srcType isEqualToString:@"11"]) {
            self.webView.hidden = NO;
            [self openWebSite:_videoId];
        }
        else if ([episode.srcType isEqualToString:@"12"]) {
            self.webView.hidden = NO;
            [self openWithVideoUrl:_videoId];
        }
        else if ([episode.srcType isEqualToString:@"14"]) {
            self.webView.hidden = NO;
            [self loadMThaiWebVideo];
        }
        else if ([episode.srcType isEqualToString:@"15"]) {
            self.webView.hidden = NO;
            [self loadMThaiWebVideoWithPassword:episode.password];
        }
    }
}


- (void) initOtvVideoPlayer:(NSInteger)row sectionOfVideo:(long)section {
    self.webView.hidden = YES;
    if (section == SECTION_VIDEO) {
        if (self.otvEpisode) {
            _part = [self.otvEpisode.parts objectAtIndex:row];
            if ([self.otvEpisode.parts count] == 1 || [self.otvEpisode.parts count] == 0) {
                self.partNameLabel.hidden = YES;
            } else {
                self.partNameLabel.hidden = NO;
            }
            
            self.episodeNameLabel.text = self.otvEpisode.date;
            self.viewCountLabel.text = _part.nameTh;
            self.partNameLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)row + 1, (long)self.otvEpisode.parts.count ];
            [self.thumbnailOTV setImageWithURL:[NSURL URLWithString: _part.thumbnail]
                              placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"]];

        }
        
    }
}

#pragma mark - Open With

- (void) openWithYoutubePlayerEmbed:(NSString *)videoIdString {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoIdString];
	[self.videoPlayerViewController presentInView:self.videoContainerView];
    [self.videoPlayerViewController.moviePlayer play];
    
    [SVProgressHUD dismiss];
 
}

- (void)openWithDailymotionEmbed {
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
                            <body style=\"background-color:#000 ;\">\
                            <iframe style=\"margin: auto; position: absolute; top: 0; left: 0; bottom: 0; right: 0;\" src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </body></html>", _videoId, _size.width, _size.height];
    
    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
}

- (void)openWebSite:(NSString *)stringUrl {
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]]];
    [SVProgressHUD dismiss];
   
}

- (void) openWithVideoUrl:(NSString *)videoUrl {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    // HTML to embed YouTube video
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><video poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" controls autoplay>\
    <source src=\"%@\" />\
    </video></div></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      [self.episode videoThumbnail:_idx],
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
    [SVProgressHUD dismiss];
}

#pragma mark - Load Video Mthai

- (void) loadMThaiWebVideo {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]
             forHTTPHeaderField:@"User-Agent"];
    manager.requestSerializer = requestSerializer;
    
    [manager GET:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]
     //    [manager GET:@"http://cms.makathon.com/user_agent.php"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
             //        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             //        NSLog(@"%@", string);
             [self startMThaiVideoFromData:responseObject];
              [SVProgressHUD dismiss];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             DLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
         }];
    
}

- (void) loadMThaiWebVideoWithPassword:(NSString *)password {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]
             forHTTPHeaderField:@"User-Agent"];
    manager.requestSerializer = requestSerializer;
    
    [manager POST:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]
       parameters:@{@"clip_password": password}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
//              NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//              NSLog(@"%@", string);
              [self startMThaiVideoFromData:responseObject];
               [SVProgressHUD dismiss];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //        NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }];
    
}

- (void) startMThaiVideoFromData:(NSData *)data {

    
    NSString *responseDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *clipUrl = nil;
    NSString *varKey = @"defaultClip";
    NSRange indexStart = [responseDataString rangeOfString:varKey];
    if (indexStart.location != NSNotFound)
    {
        clipUrl = [responseDataString substringFromIndex:indexStart.location + indexStart.length];
        NSRange indexEnd = [clipUrl rangeOfString:@";"];
        if (indexEnd.location != NSNotFound)
        {
            clipUrl = [clipUrl substringToIndex:indexEnd.location];
            clipUrl = [[[clipUrl stringByReplacingOccurrencesOfString:@" " withString:@""]
                                stringByReplacingOccurrencesOfString:@"=" withString:@""]
                                stringByReplacingOccurrencesOfString:@"'" withString:@""];

        }
        
        NSArray *seperateUrl = [clipUrl componentsSeparatedByString:@"/"];
        if ([seperateUrl[seperateUrl.count - 1] hasPrefix:_videoId]) {
            [self openWithVideoUrl:clipUrl];
            return;
        }
    }
    
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    if (error) {
        DLog(@"Error: %@", error);
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *sourceNodes = [bodyNode findChildTags:@"source"];
    
    for (HTMLNode *sourceNode in sourceNodes)
    {
        if ([sourceNode getAttributeNamed:@"src"]) {
            NSString *videoUrl = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            if ([videoUrl rangeOfString:_videoId].location != NSNotFound) {
                if ([videoUrl hasSuffix:@"flv"]) {
                    DLog(@"FLV");
                    [SVProgressHUD  showErrorWithStatus:@"Cannot play flv file."];
                    return;
                }
                else
                {
                    [self openWithVideoUrl:videoUrl];
                    DLog(@"videoUrl : %@", videoUrl);
                    
                    //                    UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithTitle:@"Play"
                    //                                                                                   style:UIBarButtonItemStylePlain
                    //                                                                                  target:self
                    //                                                                                  action:@selector(playVideo:)];
                    //                    self.navigationItem.rightBarButtonItem = playButton;
                }
                return;
            }
        }
    }
    
    [SVProgressHUD  showErrorWithStatus:@"Video have problem!"];
}


- (void) setSelectedPositionOfVideoPartAtRow:(long)row section:(long)section {
    NSIndexPath *indexPathOfVideoPart=[NSIndexPath indexPathForRow:row inSection:section];
    if ([self.tableOfVideoPart cellForRowAtIndexPath:indexPathOfVideoPart] ) {
        [self.tableOfVideoPart selectRowAtIndexPath: indexPathOfVideoPart
                                           animated:YES
                                     scrollPosition:UITableViewScrollPositionMiddle];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	// Beware, viewWillDisappear: is called when the player view enters full screen on iOS 6+
	if ([self isMovingFromParentViewController])
		[self.videoPlayerViewController.moviePlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.videoPlayerViewController.moviePlayer stop];
    }];
}

- (IBAction)playOTVButtonTapped:(id)sender {
    [self startOTV];
}

- (void)startOTV {
    if (self.show.isOTV) {
        _isContent = NO;
        [self playCurrentVideo];
    }

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == SECTION_VIDEO) {
        if (self.show.isOTV) {
            return [self.otvEpisode.parts count];
        } else {
            return [self.episode.videos count];
        }
        
    } else if (section == SECTION_RELATED) {
        if (self.show.isOTV) {
            return [self.otvRelateShows count];
        } else {
            return [self.otherEpisode.videos count];
        }
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    VideoPartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:videoPartCell];
    cell.selectedBackgroundView = selectedBackgroundViewForCell;
    
    if (indexPath.section == SECTION_VIDEO) {
        if (self.show.isOTV) {
            [cell configureWithOTVVideoPart:self.otvEpisode partNumber:indexPath.row];
        } else {
            [cell configureWithVideoPart:self.episode partNumber:indexPath.row];
        }
    }  else if (indexPath.section == SECTION_RELATED){
        if (self.show.isOTV) {
            Show *otvRelateShow = [self.otvRelateShows objectAtIndex:indexPath.row];
            [cell configureWithOTVRelateShows:otvRelateShow];
        } else {
            [cell configureWithVideoPart:self.otherEpisode partNumber:indexPath.row];
        }
    }

    return cell;
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (section == SECTION_RELATED) {
            if (self.show.isOTV) {
                return @"Relate shows";
            }
            else {
                return @"Other videos";
            }
    }
    
    return @"Playlists";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /* re assign value to _idx inorder to use in openWithVideoUrl method to show thumbnail of video */
    _idx = indexPath.row;
    
    if (indexPath.section == SECTION_VIDEO || !self.show.isOTV) {
        [self initVideoPlayer:_idx sectionOfVideo:indexPath.section];
        [self startOTV];
        
    }
    else if (self.show.isOTV && indexPath.section == SECTION_RELATED) {
        
        [self.otvEPController setShow:self.otvRelateShows[indexPath.row]];
        [self.otvEPController reload];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:webIFrameSegue]) {
//        OTVPart *otvPart = (OTVPart *)sender;
//        WebIFrameViewController *webIframeViewController = segue.destinationViewController;
//        webIframeViewController.part = otvPart;
//    }
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
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
        
//        id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
//                                                             trackingId:kOTVTracker];
//        [tracker2 set:kGAIScreenName
//                value:@"Player"];
//        [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:videoAds.URL
//                                                           forKey:[GAIFields customDimensionForIndex:4]] build]];
        
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



- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    if (!_isContent && self.videoAds) {
        [self.videoAds hitTrackingEvent:COMPLETE];
//        id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
//                                                             trackingId:kOTVTracker];
//        [tracker2 set:kGAIScreenName
//                value:@"Player"];
//        [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:self.videoAds.URL
//                                                           forKey:[GAIFields customDimensionForIndex:5]] build]];
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
//                id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
//                                                                     trackingId:kOTVTracker];
//                [tracker2 set:kGAIScreenName
//                        value:@"OTVEpisode"];
//                [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:iframeURL
//                                                                   forKey:[GAIFields customDimensionForIndex:6]] build]];
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

//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (void) viewDidAppear: (BOOL) animated {
//    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
//}
//
//- (void) viewWillDisappear: (BOOL) animated {
//    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    [self resignFirstResponder];
//}

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

#pragma mark - Video Operations

- (void)playCurrentVideo
{
    self.webView.hidden = YES;
    
    DLog(@"vastURL : %@", _part.vastURL);
    
    if (_isContent) {
        if ([_part.mediaCode isEqualToString:kCodeStream])
        {
            [self playMovieStream:[NSURL URLWithString:_part.streamURL]];
            
//            id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
//                                                                 trackingId:kOTVTracker];
//            [tracker2 set:kGAIScreenName
//                    value:@"OTVEpisode"];
//            [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:_part.streamURL
//                                                               forKey:[GAIFields customDimensionForIndex:6]] build]];
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
        
//        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
            
            _part = [self.otvEpisode.parts objectAtIndex:_idx];
            
//            [self initializeUI];
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
        
//        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
//            [self initializeUI];
            
        } else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        return YES;
    } else {
        return NO;
    }
}


@end
