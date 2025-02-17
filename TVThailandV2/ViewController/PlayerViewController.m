//
//  PlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "PlayerViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"
#import "HTMLParser.h"
#import <Google/Analytics.h>
#import <QuartzCore/QuartzCore.h>

#import "VideoPartTableViewCell.h"
#import "OTVEpisodePartViewController.h"
#import "InfoOfEpisodeViewController.h"
#import "WebViewController.h"

#import "Show.h"
#import "Episode.h"
#import "OTVEpisode.h"
#import "OTVPart.h"

#import "VKVideoPlayerCaptionSRT.h"
#import "VKVideoPlayerView.h"
#import "VKVideoPlayerLayerView.h"
#import "VKVideoPlayerAirPlay.h"

const char *AdEventNames[] = {
    "Ad Break Ready", "All Ads Completed", "Clicked", "Complete", "First Quartile", "Loaded",
    "Midpoint", "Pause", "Resume", "Skipped", "Started", "Tapped", "Third Quartile",
};

@interface PlayerViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAWebOpenerDelegate, IMAContentPlayhead>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerHeight;

@property(nonatomic, assign) CGRect portraitVideoFrame;
@property(nonatomic, assign) CGRect fullscreenVideoFrame;

@property(nonatomic, assign) BOOL isFullscreen;
@property(nonatomic, assign) BOOL isPhone;

//VK Property
@property (nonatomic, strong) NSString *currentLanguageCode;


@property (nonatomic, strong) NSArray *objClipArray;

@end

@implementation PlayerViewController {
    NSString *_videoId;
    BOOL _isContent;
    BOOL _isLoading;
    OTVPart *_part;
    AVPlayerLayer *_layer;
    NSString *_sourceType;
}

#pragma mark - Staic Variable
static int SECTION_VIDEO = 0;
static int SECTION_RELATED = 1;
static NSString *videoPartCell = @"videoPartCell";
static NSString *kCodeStream = @"1000";
static NSString *kCodeAds = @"1001";
static NSString *kCodeIframe = @"1002";
static NSString *InfoOfEPSegue = @"InfoOfEPSegue";
static NSString *ShowWebViewSegue = @"ShowWebViewSegue";

#pragma mark - UIViewController Override

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initInstance];
    [self initLableContainner];
    [self viewDidEnterPortrait];
    
    if (self.show) {
        _part = [self.otvEpisode.parts objectAtIndex:0];
        [self initVideoPlayer:_idx sectionOfVideo:0];
    }

    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    
}

- (void)initInstance {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.isPhone = !([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    if (self.isPhone) {
        self.videoContainerWidth.constant = screenRect.size.width;
        self.videoContainerHeight.constant = self.videoContainerWidth.constant * 4 / 6;
    }
    self.portraitVideoFrame = CGRectMake(0, 0, self.videoContainerWidth.constant, self.videoContainerHeight.constant);
    self.fullscreenVideoFrame = (self.isPhone) ? CGRectMake(0, 0, screenRect.size.height, screenRect.size.width): CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.webView.delegate = self;
}

#pragma mark - Implement Rotate

- (void)viewDidRotate {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self viewDidEnterLandscape];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self viewDidEnterPortrait];
        default:
            break;
    }
}

- (void)viewDidEnterPortrait {
    self.isFullscreen = NO;
    self.player.view.frame = self.portraitVideoFrame;
    self.videoContainerView.frame = self.portraitVideoFrame;
    [self.tableOfVideoPart reloadData];
}

- (void)viewDidEnterLandscape {
    self.isFullscreen = YES;
    self.player.view.frame = self.fullscreenVideoFrame;
    self.videoContainerView.frame = self.fullscreenVideoFrame;
    [self.tableOfVideoPart reloadData];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self viewDidRotate];
}

- (void) initLableContainner {
    
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
        self.infoOfEpisodeButton.hidden = NO;
        self.openWithButton.hidden = YES;
        [self initOtvVideoPlayer:row sectionOfVideo:section];
    }
    else {
        self.infoOfEpisodeButton.hidden = YES;
        
        [self initTvThVideoPlayer:row sectionOfVideo:section];
    }
    
    [self.tableOfVideoPart reloadData];
    
    [self setSelectedPositionOfVideoPartAtRow:row section:section];
    
    [VKSharedAirplay setup];
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
        _sourceType = episode.srcType;
        _videoId = episode.videos[row];
        self.episodeNameLabel.text = episode.titleDisplay;
        self.viewCountLabel.text = episode.viewCount;
        self.partNameLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)row + 1, (long)episode.videos.count ];
        
        [self.openWithButton setImage:[UIImage imageNamed:@"open_with_web"] forState:UIControlStateNormal];
        if ([_sourceType isEqualToString:@"0"]) {
            self.webView.hidden = NO;
            [self.openWithButton setImage:[UIImage imageNamed:@"open_with_youtube"] forState:UIControlStateNormal];
            self.openWithButton.hidden = NO;
            [self openWithYoutubePlayerEmbed:_videoId];
        }
        else if ([_sourceType isEqualToString:@"1"]) {
            self.webView.hidden = NO;
            [self.openWithButton setImage:[UIImage imageNamed:@"open_with_dailymotion"] forState:UIControlStateNormal];
            self.openWithButton.hidden = NO;
            [self openWithDailymotionEmbed];
        }
        else if ([_sourceType isEqualToString:@"11"]) {
            [SVProgressHUD showWithStatus:@"Loading..."];
            self.webView.hidden = YES;
            self.openWithButton.hidden = YES;
            [self.thumbnailOTV sd_setImageWithURL:[NSURL URLWithString: [self.show thumbnailUrl] ]
                              placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"] options:SDWebImageProgressiveDownload];

            [SVProgressHUD dismiss];
        }
        else if ([_sourceType isEqualToString:@"12"]) {
            self.webView.hidden = NO;
            self.openWithButton.hidden = YES;
            [self openWithVideoUrl:_videoId];
        }
        else if ([_sourceType isEqualToString:@"14"] || [_sourceType isEqualToString:@"13"]) {
            self.webView.hidden = NO;
            self.openWithButton.hidden = NO;
            [self loadMThaiWebVideo];
        }
        else if ([_sourceType isEqualToString:@"15"]) {
            self.webView.hidden = NO;
            self.openWithButton.hidden = NO;
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
            [self.thumbnailOTV sd_setImageWithURL:[NSURL URLWithString: _part.thumbnail]
                              placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"] options:SDWebImageProgressiveDownload];

        }
        
    }
}


- (void) setSelectedPositionOfVideoPartAtRow:(long)row section:(long)section {
    NSIndexPath *indexPathOfVideoPart=[NSIndexPath indexPathForRow:row inSection:section];
    if ([self.tableOfVideoPart cellForRowAtIndexPath:indexPathOfVideoPart] ) {
        [self.tableOfVideoPart selectRowAtIndexPath: indexPathOfVideoPart
                                           animated:YES
                                     scrollPosition:UITableViewScrollPositionMiddle];
    }

}

//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
//#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self.player pauseContent];
    [self.player.view removeFromSuperview];
    
    self.player = nil;
}

#pragma mark UIOutlet function implementations

- (IBAction)partInfoButtonTapped:(id)sender {
    
    [self performSegueWithIdentifier:InfoOfEPSegue sender:self.otvEpisode];
    
}
- (IBAction)openWithButtonTapped:(id)sender {
    
    [self openWebSite:_videoId];
    
}

- (IBAction)closeButtonTapped:(id)sender {
    [SVProgressHUD dismiss];

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)playOTVButtonTapped:(id)sender {

    if (self.otvEpisode && self.show.isOTV) {
        [self startOTV];
        self.playButton.hidden = YES;
    } else {
        [self openWebSite:_videoId];
        
    }
   
}


- (void)startOTV {
    if (self.show.isOTV && !_isLoading) {
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
    
    if ([segue.identifier isEqualToString:InfoOfEPSegue]) {
        InfoOfEpisodeViewController *infoOfEpisodeViewController = segue.destinationViewController;
        infoOfEpisodeViewController.otvEpisode = (OTVEpisode *)sender;
    } else if ([segue.identifier isEqualToString:ShowWebViewSegue]) {
        WebViewController *webViewController = segue.destinationViewController;
        webViewController.stringUrl = (NSString *)sender;
    }
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (void) openWithIFRAME:(NSString *)iframeText {
    //    [self performSegueWithIdentifier:webIFrameSegue sender:_part];
    self.videoContainerView.hidden = NO;
    self.webView.layer.zPosition = MAXFLOAT;
    self.webView.hidden = NO;
    [SVProgressHUD dismiss];
    
    
    NSString *iframeHtml= [self htmlEntityDecode:iframeText];
//    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
//                            <meta name = \"viewport\" content = \"user-scalable = no, width = %0.0f\"/></head>\
//                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
//                            %@</body></html>", _widthOfCH7iFrame, iframeHtml];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    //    [self.webView loadHTMLString:htmlString
//                         baseURL:nil];
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
                [self performSegueWithIdentifier:ShowWebViewSegue sender:iframeURL];
                [self sendTrackerPlayContent:iframeURL];
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

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                
                if (self.player.state == VKVideoPlayerStateContentPlaying) {
                    [self.player pauseButtonPressed];
                } else {
                    [self.player playButtonPressed];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self.player nextTrackButtonPressed];
                break;

            default:
                break;
        }
    }
}

#pragma mark - Video Operations

- (void) playNextOTVVideo {
    
    self.adsLoader = nil;
    if (self.show.isOTV &&  _idx+1 < self.otvEpisode.parts.count) {
        _idx++;
        [self initVideoPlayer:_idx sectionOfVideo:0];
        [self startOTV];
    } else {
        self.player.view.nextButton.enabled = NO;
    }
    
    [self setVideoTitleToTopLayer];
}

- (void) playPreviousOTVVideo {
    
    if (self.show.isOTV &&  _idx - 1 > 0) {
        _idx--;
        [self initVideoPlayer:_idx sectionOfVideo:0];
        [self startOTV];
    }
    
    [self setVideoTitleToTopLayer];
}

- (void)playCurrentVideo
{
    if (!_isLoading) {
        
        self.webView.hidden = YES;
        
        DLog(@"vastURL : %@", _part.vastURL);
        //  && ![_part.mediaCode isEqualToString: kCodeIframe]
        if (self.player.view == nil) {
            [self setUpVKContentPlayer];
        }
        
        if (_isContent || _part.vastURL == nil ) {
            if ([_part.mediaCode isEqualToString:kCodeStream]) {
                [self playStream:[NSURL URLWithString:_part.streamURL]];
                [self sendTrackerPlayContent:_part.streamURL];
            }
            else if ([_part.mediaCode isEqualToString:kCodeIframe]) {
                [self openWithIFRAME:_part.streamURL];
            }

        } else {
            [self setUpIMA];
            
            if ([_part.mediaCode isEqualToString:kCodeStream]) {
                
            }
          
            DLog(@"Ads Type: %@", _part.vastType);
//            if ([_part.vastType isEqualToString:@"videoplaza"] || [_part.vastType isEqualToString:@"google_ima"]) {
                [self requestAdsWithTag:_part.vastURL];
//            }
        }
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self performSegueWithIdentifier:ShowWebViewSegue sender:[[request URL] absoluteString]];
        return NO;
    }
    return YES;
}


#pragma mark IMA SDK methods

// Initialize ad display container.
- (IMAAdDisplayContainer *)createAdDisplayContainer {
    // Create our AdDisplayContainer. Initialize it with our videoView as the container. This
    // will result in ads being displayed over our content video.
    
    if (!self.adDisplayContainer) {
        self.adDisplayContainer = [[IMAAdDisplayContainer alloc] initWithAdContainer:self.player.view
                                                                      companionSlots:nil];
    }
    
    return self.adDisplayContainer;
}

- (void)setupAdsLoader {
    // Initalize Google IMA ads Loader.
    if (self.adsLoader) {
        self.adsLoader = nil;
    }
    IMASettings *settings = [[IMASettings alloc] init];
    settings.language = @"en";
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:settings];
}

// Initialize AdsLoader.
- (void)setUpIMA {
    [self setupAdsLoader];
    if (self.adsManager) {
        [self.adsManager destroy];
    }
    [self.adsLoader contentComplete];
    self.adsLoader.delegate = self;
}

// Request ads for provided tag.
- (void)requestAdsWithTag:(NSString *)adTagUrl {
    
    [self logMessage:@"Requesting ads"];
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTagUrl
                                                  adDisplayContainer:[self createAdDisplayContainer]
                                                     contentPlayhead:self.contentPlayhead
                                                         userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}

// Notify IMA SDK when content is done for post-rolls.
- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object == self.player.avPlayer.currentItem) {
        [self.adsLoader contentComplete];
    }
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    [self logMessage:@"adsLoadedWithData"];
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    [self logMessage:@"Error loading ads: %@", adErrorData.adError.message];
//    self.isAdPlayback = NO;
    _isContent = YES;
    [self playCurrentVideo];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    [self logMessage:@"AdsManager event (%s).", AdEventNames[event.type]];
    // When the SDK notified us that ads have been loaded, play them.
    // Perform different actions based on the event type.
    switch (event.type) {
        case kIMAAdEvent_LOADED: {
            _isLoading = NO;
            [self.adsManager start];
//            [self sendTrackerAdStarted:self.videoAds.URL];
        }
            break;
        case kIMAAdEvent_STARTED:
            break;
        case kIMAAdEvent_TAPPED:
//            [self viewDidEnterLandscape];
            break;
        case kIMAAdEvent_ALL_ADS_COMPLETED:
            [self.adsLoader contentComplete];
            break;
        case kIMAAdEvent_SKIPPED:
            break;
        default:
            break;
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime {

}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    [self logMessage:@"AdsManager error: %@", error.message];
    _isContent = YES;
    [self playCurrentVideo];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [self logMessage:@"adsManagerDidRequestContentPause"];
    [self.player pauseContent];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [self logMessage:@"adsManagerDidRequestContentPause"];
    _isContent = YES;
    [self playCurrentVideo];
}

#pragma mark Utility methods

- (void)logMessage:(NSString *)log, ... {
    va_list args;
    va_start(args, log);
    NSString *s =
    [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@\n", log] arguments:args];
    NSLog(@"%@", s);
    va_end(args);
}


#pragma END IMA


- (void)contentDidFinishPlaying {
    DLog(@"Content has completed");
    [self.adsLoader contentComplete];
}

- (void)updatePlayHeadWithTime:(CMTime)time duration:(CMTime)duration{
    if (CMTIME_IS_INVALID(time)) {
        return;
    }
    Float64 currentTime = CMTimeGetSeconds(time);
    if (isnan(currentTime)) {
        return;
    }
}

// Get the duration value from the player item.
- (CMTime)getPlayerItemDuration:(AVPlayerItem *)item {
    CMTime itemDuration = kCMTimeInvalid;
    if ([item respondsToSelector:@selector(duration)]) {
        itemDuration = item.duration;
    }
    else {
        if (item.asset &&
            [item.asset respondsToSelector:@selector(duration)]) {
            // Sometimes the test app hangs here for ios 4.2.
            itemDuration = item.asset.duration;
        }
    }
    return itemDuration;
}

#pragma mark IMABrowser delegate functions

- (void)willOpenExternalBrowser {
    DLog(@"External browser will open.");
}

- (void)willOpenInAppBrowser {
    DLog(@"In-app browser will open");
}

- (void)didOpenInAppBrowser {
    DLog(@"In-app browser did open");
}

- (void)willCloseInAppBrowser {
    DLog(@"In-app browser will close");
}

- (void)didCloseInAppBrowser {
    DLog(@"In-app browser did close");
}


#pragma mark - VK Player

- (void)setUpVKContentPlayer {
    if (!self.player) {
        self.player = [[VKVideoPlayer alloc] init];
        self.player.delegate = self;
        self.player.forceRotate = self.isPhone;
        self.player.view.frame = self.portraitVideoFrame;
        self.player.portraitFrame = self.portraitVideoFrame;
        self.player.landscapeFrame = self.fullscreenVideoFrame;
        self.player.view.fullscreenButton.hidden = NO;
        
        [self.view addSubview:self.player.view];
    }
    
    if (!self.contentPlayhead) {
//        self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.player.avPlayer];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(contentDidFinishPlaying:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:self.player.avPlayer.currentItem];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)playStream:(NSURL*)url {
    VKVideoPlayerTrack *track = [[VKVideoPlayerTrack alloc] initWithStreamURL:url];
    track.hasNext = YES;
    [self.player pauseContent];
    [self.player loadVideoWithTrack:track];
    
    [self setVideoTitleToTopLayer];
    
    self.player.view.nextButton.hidden = NO;
    self.player.view.rewindButton.hidden = NO;
}

- (void)playVideoStream:(NSURL*)url {
    VKVideoPlayerTrack *track = [[VKVideoPlayerTrack alloc] initWithStreamURL:url];
    [self.player pauseContent];
    [self.player loadVideoWithTrack:track];
    [self setVideoTitleToTopLayer];
}

- (void) setVideoTitleToTopLayer {
    self.player.view.titleLabel.frame = CGRectMake(30,8, self.view.bounds.size.width - 50, 30);
    self.player.view.titleLabel.text = _part.nameTh;
}
#pragma mark - App States

- (void)applicationWillResignActive {
    self.player.view.controlHideCountdown = -1;
    if (self.player.state == VKVideoPlayerStateContentPlaying) [self.player pauseContent:NO completionHandler:nil];
}

- (void)applicationDidBecomeActive {
    self.player.view.controlHideCountdown = kPlayerControlsDisableAutoHide;

}

#pragma mark - VKVideoPlayerControllerDelegate
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didControlByEvent:(VKVideoPlayerControlEvent)event {
    DLog(@"%s videoPlayer :%d", __FUNCTION__, event);
    switch (event) {
        case VKVideoPlayerControlEventTapDone:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case VKVideoPlayerControlEventTapFullScreen:
            if (self.player.isFullScreen) {
                [self viewDidEnterLandscape];
            } else {
                [self viewDidEnterPortrait];
            }
            break;
        case VKVideoPlayerControlEventTapNext:
        case VKVideoPlayerControlEventSwipeNext:
            [self playNextOTVVideo];
            break;
        case VKVideoPlayerControlEventTapPrevious:
        case VKVideoPlayerControlEventSwipePrevious:
            [self playPreviousOTVVideo];
            break;
        case VKVideoPlayerControlEventTapVideoQuality:
            [self tapVideoQuality];
            break;
        default:
            break;
    }
}

- (void) tapVideoQuality {
    
    if (self.objClipArray) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Quality" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        for (NSDictionary *objClip in self.objClipArray) {
            NSString *res = [objClip objectForKey:@"label"];
            if (![res isEqualToString:@"auto"]) {
                res = [NSString stringWithFormat:@"%@p", [objClip objectForKey:@"label"]];
            }
            NSString *src = [objClip objectForKey:@"file"];
            UIAlertAction *selectQualityAction = [UIAlertAction actionWithTitle:res style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self playVideoStream:[NSURL URLWithString:src]];
                self.player.view.videoQualityButton.titleLabel.text = res;
            }];
            [alert addAction:selectQualityAction];
        }
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }

}

/** This method is called finished to play video. You can start to play next video here. **/
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didPlayToEnd:(id<VKVideoPlayerTrackProtocol>)track {
    [self playNextOTVVideo];
    
}


#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return self.isPhone;
}

- (void)videoPlayer:(VKVideoPlayer*)videoPlayer willChangeOrientationTo:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self viewDidEnterLandscape];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self viewDidEnterPortrait];
        case UIInterfaceOrientationUnknown:
            break;
    }
}

- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didChangeOrientationFrom:(UIInterfaceOrientation)fromInterfaceOrientation {
//    switch (fromInterfaceOrientation) {
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//            [self viewDidEnterPortrait];
//            break;
//        case UIInterfaceOrientationPortrait:
//        case UIInterfaceOrientationPortraitUpsideDown:
//            [self viewDidEnterLandscape];
//        case UIInterfaceOrientationUnknown:
//            break;
//    }
}

     

#pragma mark - Send Tracker

- (void)sendTrackerAdStarted:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createScreenView] set:url
                                                       forKey:[GAIFields customDimensionForIndex:4]] build]];
}

- (void)sendTrackerAdCompleted:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createScreenView] set:url
                                                       forKey:[GAIFields customDimensionForIndex:5]] build]];
}

- (void)sendTrackerPlayContent:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createScreenView] set:url
                                                       forKey:[GAIFields customDimensionForIndex:6]] build]];
}

//- (BOOL)shouldVideoPlayer:(VKVideoPlayer*)videoPlayer changeStateTo:(VKVideoPlayerState)toState
//{
//    
//}
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer willChangeStateTo:(VKVideoPlayerState)toState {
    
}
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didChangeStateFrom:(VKVideoPlayerState)fromState {
    
}
//- (BOOL)shouldVideoPlayer:(VKVideoPlayer*)videoPlayer startVideo:(id<VKVideoPlayerTrackProtocol>)track;


#pragma mark - Open With

- (void) openWithYoutubePlayerEmbed:(NSString *)videoIdString {
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.playButton.hidden = YES;
    self.webView.hidden = NO;
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
                            <body style=\"background-color:#000 ;\">\
                            <iframe  style=\"margin: auto; position: absolute; top: 0; left: 0; bottom: 0; right: 0;\"  id=\"player\" type=\"text/html\" width=\"%0.0f\" height=\"%0.0f\" src=\"https://www.youtube.com/embed/%@?enablejsapi=1&origin=http://www.code-mobi.com\" frameborder=\"0\"></iframe></body></html>", self.portraitVideoFrame.size.width, self.portraitVideoFrame.size.height, _videoId];
    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",_videoId]]];
    
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
    
}

- (void)openWithDailymotionEmbed {
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
                            <body style=\"background-color:#000 ;\">\
                            <iframe style=\"margin: auto; position: absolute; top: 0; left: 0; bottom: 0; right: 0;\" src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </body></html>", _videoId, self.portraitVideoFrame.size.width, self.portraitVideoFrame.size.height];
    
    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
}

- (void)openWebSite:(NSString *)stringUrl {
    if ([_sourceType isEqualToString:@"0"]) {
//        [self performSegueWithIdentifier:ShowWebViewSegue sender:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",_videoId]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",_videoId]]];
    } else if ([_sourceType isEqualToString:@"1"]) {
        [self performSegueWithIdentifier:ShowWebViewSegue sender:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]];
    } else if ([_sourceType isEqualToString:@"11"]) {
//        [self performSegueWithIdentifier:ShowWebViewSegue sender:stringUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringUrl]];
    } else if ([_sourceType isEqualToString:@"13"] || [_sourceType isEqualToString:@"14"] || [_sourceType isEqualToString:@"15"]) {
                NSString *mthaiUrl = [NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html", stringUrl];
        
        if ([_sourceType isEqualToString:@"15"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Video has password"
                                                                           message:[NSString stringWithFormat:@"Password : %@", self.episode.password]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mthaiUrl]];
                    }];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mthaiUrl]];
        }
//        [self performSegueWithIdentifier:ShowWebViewSegue sender:mthaiUrl];

    }
}

- (void) openWithVideoUrl:(NSString *)videoUrl {
    [self setUpVKContentPlayer];
    [self playVideoStream:[NSURL URLWithString:videoUrl]];
}

#pragma mark - Load Video Mthai

- (void) loadMThaiWebVideo {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] forHTTPHeaderField:@"User-Agent"];
    [manager GET:url.absoluteString
      parameters:nil progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [self startMThaiVideoFromData:responseObject];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [SVProgressHUD showErrorWithStatus:@"Video cannot play!"];
         }];
}

- (void) loadMThaiWebVideoWithPassword:(NSString *)password {
    NSString *userAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url.absoluteString
      parameters:nil progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             if (url.absoluteString != [task response].URL.absoluteString)
             {
                 NSLog(@"%@", [task response].URL.absoluteString);
                 [self loadMThaiWebVideoWithURL:[task response].URL Password:password UserAgent:userAgent];
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
         }];
}

- (void) loadMThaiWebVideoWithURL:(NSURL *)url Password:(NSString *)password UserAgent:(NSString *)userAgent  {
    NSDictionary *params = @{@"clip_password": password};
    NSMutableArray *parameterArray = [NSMutableArray arrayWithCapacity:[params count]];
    for (NSString *key in params) {
        [parameterArray addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    
    NSString *postBodyString = [parameterArray componentsJoinedByString:@"&"];
    NSData *postBodyData = [NSData dataWithBytes:[postBodyString UTF8String] length:[postBodyString length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postBodyData];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url.absoluteString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self startMThaiVideoFromData:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"Video cannot play!"];
    }];
    
//    NSURLSessionTask *op = [[NSURLSessionTask alloc] initWithRequest:request];
//    [op setRedirectResponseBlock:^NSURLRequest * _Nonnull(NSURLConnection * _Nonnull connection, NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull redirectResponse) {
//        if (redirectResponse) {
//            NSLog(@"%@",request.URL);
//        }
//        return request;
//    }];
//    [op setCompletionBlockWithSuccess:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
//        [self startMThaiVideoFromData:responseObject];
//    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
//        [SVProgressHUD showErrorWithStatus:@"Video cannot play!"];
//    }];
//    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void) startMThaiVideoFromData:(NSData *)data {
    NSString *responseDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([self mThaiSeperateByObClip:responseDataString])
        return;
    
    if([self mThaiSeperateByDefaultClip:responseDataString])
        return;

    
    [self openWebSite:_videoId];
}

- (BOOL) mThaiSeperateByObClip:(NSString *)responseDataString {
    NSString *varKey = @"sources_temp = ";
    NSRange indexStart = [responseDataString rangeOfString:varKey];
    if (indexStart.location != NSNotFound)
    {
        NSString *clipUrl = [responseDataString substringFromIndex:indexStart.location + indexStart.length];
        NSRange indexEnd = [clipUrl rangeOfString:@";"];
        if (indexEnd.location != NSNotFound)
        {
            NSString *obClipString = [clipUrl substringToIndex:indexEnd.location];
            NSError *error = nil;
            NSData *jsonData = [obClipString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *objClipArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (objClipArray && obClipString.length > 0) {
                self.objClipArray = [NSArray arrayWithArray:objClipArray];
                for (NSDictionary *objClip in self.objClipArray) {
                    NSString *res = [objClip objectForKey:@"label"];
                    if (![res isEqualToString:@"auto"]) {
                        res = [NSString stringWithFormat:@"%@p", [objClip objectForKey:@"label"]];
                    }
                    NSString *clipUrl = [objClip objectForKey:@"file"];
                    [self openWithVideoUrl:clipUrl];
                    self.player.view.videoQualityButton.titleLabel.text = res;
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL) mThaiSeperateByDefaultClip:(NSString *)responseDataString {
    NSString *varKey = @"defaultClip";
    NSRange indexStart = [responseDataString rangeOfString:varKey];
    if (indexStart.location != NSNotFound)
    {
        NSString *clipUrl = [responseDataString substringFromIndex:indexStart.location + indexStart.length];
        NSRange indexEnd = [clipUrl rangeOfString:@";"];
        if (indexEnd.location != NSNotFound)
        {
            clipUrl = [clipUrl substringToIndex:indexEnd.location];
            clipUrl = [[[clipUrl stringByReplacingOccurrencesOfString:@" " withString:@""]
                        stringByReplacingOccurrencesOfString:@"=" withString:@""]
                       stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
        }
        [self openWithVideoUrl:clipUrl];
        return YES;
    }
    return NO;
}

@end
