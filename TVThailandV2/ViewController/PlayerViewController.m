//
//  PlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "PlayerViewController.h"
#import "IAHTTPCommunication.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"
#import "HTMLParser.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DVInlineVideoAd.h"
#import <QuartzCore/QuartzCore.h>
#import "CMVideoAds.h"

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

const char* AdEventNames[] = {
    "All Ads Complete",
    "Clicked",
    "Complete",
    "First Quartile",
    "Loaded",
    "Midpoint",
    "Pause",
    "Resume",
    "Third Quartile",
    "Started",
};

typedef enum {
    PlayButton,
    PauseButton
} PlayButtonType;

@interface PlayerViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, CMVideoAdsDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAWebOpenerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTopSpace;

@property(nonatomic, assign) CGRect portraitVideoFrame;
@property(nonatomic, assign) CGRect fullscreenVideoFrame;

@property(nonatomic, assign) BOOL isFullscreen;
@property(nonatomic, assign) BOOL isPhone;


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


//VK Property
@property (nonatomic, strong) NSString *currentLanguageCode;

// Private functions
- (void)unloadAdsManager;


@end

@implementation PlayerViewController {
    NSString *_videoId;
    CGSize _size;
    BOOL _isContent;
    BOOL _isLoading;
    OTVPart *_part;
    AVPlayerLayer *_layer;
    NSString *_sourceType;
    
    UIButton *_skipAdsButton;
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
    
    if (self.show) {
        _part = [self.otvEpisode.parts objectAtIndex:0];
        [self initVideoPlayer:_idx sectionOfVideo:0];
    }

    [self viewDidEnterPortrait];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    
    [self initSkipAdsButton];
}

- (void)initInstance {
    self.isPhone = !([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    self.portraitVideoFrame = CGRectMake(0, 0, self.videoContainerWidth.constant, self.videoContainerHeight.constant);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.fullscreenVideoFrame = (self.isPhone) ? CGRectMake(0, 0, screenRect.size.height, screenRect.size.width): CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.webView.delegate = self;
}

-(void) skipAdsButtonTouched {
    [self unloadAdsManager];
    [self sendTrackerAdCompleted:self.videoAds.URL];
    _isContent = YES;
    [self playCurrentVideo];
}

-(void)initSkipAdsButton {
    
     _skipAdsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_skipAdsButton addTarget:self
                      action:@selector(skipAdsButtonTouched)
            forControlEvents:UIControlEventTouchUpInside];
    [_skipAdsButton setTitle:@"skip" forState:UIControlStateNormal];
    [_skipAdsButton setTitle:@"skip in 8 s" forState:UIControlStateDisabled];
    [_skipAdsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CALayer * layer = [_skipAdsButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:0.0]; //when radius is 0, the border is a rectangle
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    switch (fromInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self viewDidEnterPortrait];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self viewDidEnterLandscape];
        case UIInterfaceOrientationUnknown:
            break;
    }
}

#pragma mark - Private Method

- (void)viewDidEnterPortrait {
    self.isFullscreen = NO;
    self.player.view.frame = self.portraitVideoFrame;
    self.videoContainerView.frame = self.portraitVideoFrame;
    
//    self.adDisplayContainer.adContainer.frame = self.portraitVideoFrame;
//    [UIView animateWithDuration:0.3f animations:^{
//        _skipAdsButton.frame = CGRectMake(self.adDisplayContainer.adContainer.bounds.size.width-100, self.adDisplayContainer.adContainer.bounds.size.height-70, 90, 25);
//    }];
    [self.tableOfVideoPart reloadData];
}

- (void)viewDidEnterLandscape {
    self.isFullscreen = YES;
    self.player.view.frame = self.fullscreenVideoFrame;
//    self.adDisplayContainer.adContainer.frame = self.fullscreenVideoFrame;
//    [UIView animateWithDuration:0.3f animations:^{
//        _skipAdsButton.frame = CGRectMake(self.adDisplayContainer.adContainer.bounds.size.width-100, self.adDisplayContainer.adContainer.bounds.size.height-70, 90, 25);
//    }];
    
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
            [self.thumbnailOTV setImageWithURL:[NSURL URLWithString: [self.show thumbnailUrl] ]
                              placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"]];

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
            [self.thumbnailOTV setImageWithURL:[NSURL URLWithString: _part.thumbnail]
                              placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"]];

        }
        
    }
}

#pragma mark - Open With

- (void) openWithYoutubePlayerEmbed:(NSString *)videoIdString {
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.webView.hidden = NO;
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
                            <body style=\"background-color:#000 ;\">\
                            <iframe  style=\"margin: auto; position: absolute; top: 0; left: 0; bottom: 0; right: 0;\"  id=\"player\" type=\"text/html\" width=\"%0.0f\" height=\"%0.0f\" src=\"http://www.youtube.com/embed/%@?enablejsapi=1&origin=http://www.code-mobi.com\" frameborder=\"0\"></iframe></body></html>", _size.width, _size.height, _videoId];
    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]]];

    [self.webView.scrollView setScrollEnabled:NO];
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
    if ([_sourceType isEqualToString:@"0"]) {
        [self performSegueWithIdentifier:ShowWebViewSegue sender:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]];
    } else if ([_sourceType isEqualToString:@"1"]) {
        [self performSegueWithIdentifier:ShowWebViewSegue sender:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]];
    } else if ([_sourceType isEqualToString:@"11"]) {
        [self performSegueWithIdentifier:ShowWebViewSegue sender:stringUrl];
    } else if ([_sourceType isEqualToString:@"13"] || [_sourceType isEqualToString:@"14"] || [_sourceType isEqualToString:@"15"]) {
        if ([_sourceType isEqualToString:@"15"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video has password"
                                                            message:[NSString stringWithFormat:@"Password : %@", self.episode.password]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        NSString *mthaiUrl = [NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html", stringUrl];
        [self performSegueWithIdentifier:ShowWebViewSegue sender:mthaiUrl];
    }
}

- (void) openWithVideoUrl:(NSString *)videoUrl {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    // HTML to embed YouTube video
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
    <body style=\"background-color:#000 ;\">\
    <video style=\"margin: auto; position: absolute; top: 0; left: 0; right: 0; bottom: 0;\" poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" src=\"%@\" controls autoplay>\
    </video></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      [self.episode videoThumbnail:_idx],
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
    [self.webView.scrollView setScrollEnabled:NO];
    [SVProgressHUD dismiss];
}

#pragma mark - Load Video Mthai

- (void) loadMThaiWebVideo {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]];
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    [http retrieveURL:url
            userAgent:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]
         successBlock:^(NSData *response) {
             [self startMThaiVideoFromData:response];
             [SVProgressHUD dismiss];
         }];
}

- (void) loadMThaiWebVideoWithPassword:(NSString *)password {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]];
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    [http postURL:url userAgent:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]
           params:@{@"clip_password": password}
     successBlock:^(NSData *response) {
         [self startMThaiVideoFromData:response];
         [SVProgressHUD dismiss];
     }];
}

- (void) startMThaiVideoFromData:(NSData *)data {

    
    NSString *responseDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *clipUrl = nil;
    NSString *varKey = @"{ mp4:  \"http";
    NSRange indexStart = [responseDataString rangeOfString:varKey];
    if (indexStart.location != NSNotFound)
    {
        clipUrl = [responseDataString substringFromIndex:indexStart.location + indexStart.length - 4];
        NSRange indexEnd = [clipUrl rangeOfString:@"}"];
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
    NSString *videoUrl = nil;
    for (HTMLNode *sourceNode in sourceNodes)
    {
        if ([sourceNode getAttributeNamed:@"src"]) {
            NSString *videoUrl = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            if ([videoUrl rangeOfString:_videoId].location != NSNotFound) {
                if ([videoUrl hasSuffix:@"flv"]) {
                    DLog(@"FLV");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [SVProgressHUD  showErrorWithStatus:@"Video have problem!"];
                    });
                    return;
                }
                else
                {
                    [self openWithVideoUrl:videoUrl];
                    DLog(@"videoUrl : %@", videoUrl);
                }
                return;
            }
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD  showErrorWithStatus:@"Video have problem!"];
    });
    
    if (clipUrl != nil && clipUrl.length > 0) {
        [self openWithVideoUrl:clipUrl];
    } else if (videoUrl != nil && videoUrl.length > 0) {
        [self openWithVideoUrl:videoUrl];
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
    [self unloadAdsManager];
    [self.player pauseContent];
    [self.player.view removeFromSuperview];
    
    self.adsLoader = nil;
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

    [self close];
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
        
        [self close];
        [self initVideoPlayer:_idx sectionOfVideo:indexPath.section];
        [self startOTV];
        
    }
    else if (self.show.isOTV && indexPath.section == SECTION_RELATED) {
        [self unloadAdsManager];
        
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


#pragma mark - Delegate CM VideoAds

- (void)didRequestVideoAds:(CMVideoAds *)videoAds success:(BOOL)success {
    _isLoading = NO;
    [SVProgressHUD dismiss];
    //    DLog(@"%@", videoAds);
    //    DLog(@"mediaFile : %@", [videoAds.ad.mediaFileURL absoluteString]);
    //    DLog(@"streamURL : %@", _part.streamURL);
    
    if (success) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.videoAds hitTrackingEvent:START];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.videoAds hitTrackingEvent:FIRST_QUARTILE];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.videoAds hitTrackingEvent:MIDPOINT];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.videoAds hitTrackingEvent:THIRD_QUARTILE];
        });
        
        [self sendTrackerAdStarted:videoAds.URL];
        [self playMovieStream:videoAds.ad.mediaFileURL];
        
        
    }
    else
    {
        _isContent = !_isContent;
        [self playCurrentVideo];
    }
}

- (void)didRequestVideoAds:(CMVideoAds *)videoAds error:(NSError *)error {
    _isLoading = NO;
    [SVProgressHUD dismiss];
    
    _isContent = !_isContent;
    [self playCurrentVideo];
}


- (void)playMovieStream:(NSURL *)movieFileURL
{
//    if (self.movieController != nil) {
//        [self.movieController stop];
//    }
    
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMovieDurationAvailableNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player
{
    [self removeMovieNotificationHandlers:player];
}



- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = [notification object];
    if (player != self.movieController) {
        return;
    }
    if (!_isContent && self.videoAds) {
        [self.videoAds hitTrackingEvent:COMPLETE];
        [self sendTrackerAdCompleted:self.videoAds.URL];
    }
    
    [self removeMovieNotificationHandlers:player];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;

    
    _isContent = !_isContent;
    
    if (_isContent)
    {
        [self playCurrentVideo];
    }
//    else
//    {
//        if ([self moveNextVideo])
//        {
//            [self playCurrentVideo];
//        }
//    }
    
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

- (void)playCurrentVideo
{
    [self.player pauseContent];
    if (!_isLoading) {
        
        self.webView.hidden = YES;
        
        DLog(@"vastURL : %@", _part.vastURL);
        if (self.player.view == nil && ![_part.mediaCode isEqualToString: kCodeIframe]) {
            [self setUpVKContentPlayer];
        }


        
        if (_isContent || _part.vastURL == nil ) {
//            self.adDisplayContainer.adContainer.hidden = YES;
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
                [self playStream:[NSURL URLWithString:_part.streamURL]];
            }
          
            DLog(@"Ads Type: %@", _part.vastType);
            if ([_part.vastType isEqualToString:@"videoplaza"] || [_part.vastType isEqualToString:@"google_ima"]) {
                [self requestAdsWithTag:_part.vastURL];
            } else {
                self.videoAds = [[CMVideoAds alloc] initWithVastTagURL:_part.vastURL];
                self.videoAds.delegate = self;
            }
            

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
    return [[IMAAdDisplayContainer alloc] initWithAdContainer:self.player.view companionSlots:nil];
}

// Create playhead for content tracking.
- (void)createContentPlayhead {
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.player.avPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player.avPlayer currentItem]];
}

// Initialize AdsLoader.
- (void)setUpIMA {
    if (self.adsManager) {
        [self.adsManager destroy];
    }
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:[self createIMASettings]];
    [self.adsLoader contentComplete];
    self.adsLoader.delegate = self;
}

// Request ads for provided tag.
- (void)requestAdsWithTag:(NSString *)adTagUrl {
    [self logMessage:@"Requesting ads"];
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTagUrl
                                                  adDisplayContainer:[self createAdDisplayContainer]
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
    // Create a content playhead so the SDK can track our content for VMAP and ad rules.
    [self createContentPlayhead];
    // Initialize the ads manager.
    [self.adsManager initializeWithContentPlayhead:self.contentPlayhead
                              adsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    [self logMessage:@"Error loading ads: %@", adErrorData.adError.message];
//    self.isAdPlayback = NO;
    _isContent = !_isContent;
    [self playCurrentVideo];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    [self logMessage:@"AdsManager event (%s).", AdEventNames[event.type]];
    // When the SDK notified us that ads have been loaded, play them.
    // Perform different actions based on the event type.
    switch (event.type) {
        case kIMAAdEvent_LOADED:
            _isLoading = NO;
            [self.adsManager start];
            [self sendTrackerAdStarted:self.videoAds.URL];
            break;
        case kIMAAdEvent_TAPPED:
            [self viewDidEnterLandscape];
            break;
        case kIMAAdEvent_ALL_ADS_COMPLETED:
            [self unloadAdsManager];
            [self sendTrackerAdCompleted:self.videoAds.URL];
            break;
            
        default:
            break;
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    [self logMessage:@"AdsManager error: %@", error.message];
//    self.isAdPlayback = NO;
//    [self setPlayButtonType:PauseButton];
//    [self.contentPlayer play];
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

- (IMASettings *) createIMASettings {
    IMASettings *settings = [[IMASettings alloc] init];
    settings.ppid = @"IMA_PPID_0";
    settings.language = @"en";
    return settings;
}

- (void)setupAdsLoader {
    // Initalize Google IMA ads Loader.
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:[self createIMASettings]];
    // Implement delegate methods to get callbacks from the adsLoader.
    self.adsLoader.delegate = self;
}

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


//- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
//    // Loading was successful.
//    DLog(@"Ad loading successful!");
//    
//    self.adsManager = adsLoadedData.adsManager;
//    self.adsManager.delegate = self;
//    
//    self.adDisplayContainer.adContainer.frame = self.player.view.bounds;
//    
//    // By default, allow in-app web browser.
//    self.adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
//    self.adsRenderingSettings.webOpenerDelegate = self;
//    self.adsRenderingSettings.webOpenerPresentingController = self;
//    self.adsRenderingSettings.bitrate = kIMAAutodetectBitrate;
//    self.adsRenderingSettings.mimeTypes = @[];
//
//    if ([_part.mediaCode isEqualToString:kCodeIframe]) {
//        [self.view addSubview:self.adDisplayContainer.adContainer];
//
//    } else {
//        [self.player.view addSubview:self.adDisplayContainer.adContainer];
//    }
//    
//    _skipAdsButton.frame = CGRectMake(self.adDisplayContainer.adContainer.bounds.size.width-100, self.adDisplayContainer.adContainer.bounds.size.height-70, 90, 25);
//    [self.adDisplayContainer.adContainer addSubview:_skipAdsButton];
//    _skipAdsButton.enabled = NO;
//    [_skipAdsButton setTitle:@"skip in 8 s" forState:UIControlStateDisabled];
//    
//
////    self.player.view.controls.hidden = YES;
////    self.player.view.playButton.enabled = NO;
////    self.player.view.nextButton.hidden = YES;
////    self.player.view.rewindButton.hidden = YES;
////    self.player.view.bigPlayButton.hidden = YES;
////    self.player.view.activityIndicator.hidden = YES;
//    
//    [self.adsManager initializeWithContentPlayhead:nil adsRenderingSettings:self.adsRenderingSettings];
//}

//- (void)requestAdsTag:(NSString *)adTag {
//    DLog(@"Requesting ads.");
//    [self unloadAdsManager];
//    
//    self.adDisplayContainer = [[IMAAdDisplayContainer alloc] initWithAdContainer:self.videoContainerView
//                                                                  companionSlots:nil];
//    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTag
//                                                  adDisplayContainer:self.adDisplayContainer
//                                                         userContext:nil];
//    [self.adsLoader requestAdsWithRequest:request];
//}

- (void)unloadAdsManager {
    if (self.adsManager != nil) {
        [self.adsManager destroy];
        self.adsManager.delegate = nil;
        self.adsManager = nil;
    }
}

// Optional: receive updates about individual ad progress.
- (void)adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime {
    CMTime time = CMTimeMakeWithSeconds(mediaTime, 1000);
//    CMTime duration = CMTimeMakeWithSeconds(totalTime, 1000);
//    [self updatePlayHeadWithTime:time duration:duration];
    int s = (int)CMTimeGetSeconds(time);
    if (s <= 8) {
        _skipAdsButton.enabled = NO;
        [_skipAdsButton setTitle:[NSString stringWithFormat:@"skip in %d s", 8 - s] forState:UIControlStateDisabled];
    } else {
        _skipAdsButton.enabled = YES;
        [_skipAdsButton setTitle:@"skip in 8 s" forState:UIControlStateDisabled];
    }

    
//    self.progressBar.maximumValue = totalTime;
//    [self setPlayButtonType:PauseButton];
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

    self.player = [[VKVideoPlayer alloc] init];
    self.player.delegate = self;
    self.player.forceRotate = self.isPhone;
    self.player.view.frame = self.portraitVideoFrame;
    self.player.view.fullscreenButton.hidden = NO;
    
    [self.view addSubview:self.player.view];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)playStream:(NSURL*)url {
    VKVideoPlayerTrack *track = [[VKVideoPlayerTrack alloc] initWithStreamURL:url];
    track.hasNext = YES;
    [self.player loadVideoWithTrack:track];
    
    [self setVideoTitleToTopLayer];
    
    self.player.view.nextButton.hidden = NO;
    self.player.view.rewindButton.hidden = NO;
}

- (void) setVideoTitleToTopLayer {
    
    self.player.view.titleLabel.frame = CGRectMake(30,8, self.view.bounds.size.width - 50, 30);
    self.player.view.titleLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.otvEpisode.date stringByReplacingOccurrencesOfString: @"ออกอากาศ " withString:@""], _part.nameTh];
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
            self.closeCircleButton.hidden = NO;
            [self close];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case VKVideoPlayerControlEventTapFullScreen:
            if (self.player.isFullScreen) {
                self.closeCircleButton.hidden = YES;
                self.player.view.frame = self.fullscreenVideoFrame;
//                self.adDisplayContainer.adContainer.frame = self.fullscreenVideoFrame;
            } else {
                self.closeCircleButton.hidden = NO;
                self.player.view.frame = self.portraitVideoFrame;
//                self.adDisplayContainer.adContainer.frame = self.portraitVideoFrame;
            }
//            _skipAdsButton.frame = CGRectMake(self.adDisplayContainer.adContainer.bounds.size.width-100, self.adDisplayContainer.adContainer.bounds.size.height-70, 90, 25);
            break;
        case VKVideoPlayerControlEventTapNext:
        case VKVideoPlayerControlEventSwipeNext:
            [self playNextOTVVideo];
        case VKVideoPlayerControlEventTapPrevious:
        case VKVideoPlayerControlEventSwipePrevious:
//          playPrevious
            break;
        default:
            break;
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
    
//     [UIView animateWithDuration:0.3f animations:^{
//         _skipAdsButton.frame = CGRectMake(self.adDisplayContainer.adContainer.bounds.size.width-100, self.adDisplayContainer.adContainer.bounds.size.height-70, 90, 25);
//    }];
}

- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didChangeOrientationFrom:(UIInterfaceOrientation)fromInterfaceOrientation {
    switch (fromInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self viewDidEnterPortrait];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self viewDidEnterLandscape];
        case UIInterfaceOrientationUnknown:
            break;
    }
}

     

#pragma mark - Send Tracker

- (void)sendTrackerAdStarted:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:url
                                                       forKey:[GAIFields customDimensionForIndex:4]] build]];
}

- (void)sendTrackerAdCompleted:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:url
                                                       forKey:[GAIFields customDimensionForIndex:5]] build]];
}

- (void)sendTrackerPlayContent:(NSString *)url {
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName
            value:@"Player"];
    [tracker2 send:[[[GAIDictionaryBuilder createAppView] set:url
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

@end
