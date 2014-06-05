//
//  YoutubePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Episode.h"

#import "SVProgressHUD.h"

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

#import "HTMLParser.h"

#import "MakathonAdView.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface VideoPlayerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (weak, nonatomic) IBOutlet MakathonAdView *mkAdView;

@property (weak, nonatomic) IBOutlet UIToolbar *videoToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *partInfoBarButtonItem;

@end

@implementation VideoPlayerViewController {
    NSString *_videoId;
    CGSize _size;
    NSString *_spaceTop;
    NSString *_videoFile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.webView.scrollView setScrollEnabled:NO];
//    [self.mkAdView requestAd];

    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];

    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
        _spaceTop = @"0px";
    }
    else
    {
        _size = CGSizeMake(320, 240);
        _spaceTop = @"0px";
    }
    
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
//    NSLog(@"++++%s", self.isHidenToolbarPlayer ? "true" : "false");
    if (self.isHidenToolbarPlayer) {
        self.videoToolbar.hidden = YES;
    }
    
    [self enableOrDisableNextPreviousButton];
    
    //if key = channel --> hide videoToolbar
    

    
    if (self.episode) {
        
        self.navigationItem.title = self.episode.titleDisplay;
        

        
        if (self.episode.videos.count != 1  ){
            NSString *partInfo = [NSString stringWithFormat:@"Part %d/%d", (_idx + 1), self.episode.videos.count ];
            
            self.partInfoBarButtonItem.title = partInfo;
            [self.partInfoBarButtonItem setTintColor:[UIColor redColor]];

            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {

                self.videoToolbar.tintColor = [UIColor grayColor];
                [self.previousBarButtonItem setTintColor:[UIColor whiteColor]];
                [self.nextBarButtonItem setTintColor:[UIColor whiteColor]];
                
                [self.partInfoBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
            }else{
                [self.previousBarButtonItem setTintColor:[UIColor redColor]];
                [self.nextBarButtonItem setTintColor:[UIColor redColor]];
            }
            
        }else {
            self.videoToolbar.hidden = YES;
        }
        
        
        _videoId = self.episode.videos[self.idx];
        
        if ([self.episode.srcType isEqualToString:@"0"]) {
            [self openWithYoutube];
        }
        else if ([self.episode.srcType isEqualToString:@"1"]) {
            [self openWithDailymotion];
        }
        else if ([self.episode.srcType isEqualToString:@"11"]) {
            [self openWebSite:_videoId];
        }
        else if ([self.episode.srcType isEqualToString:@"12"]) {
            [self openWithVideoUrl:_videoId];
        }
        else if ([self.episode.srcType isEqualToString:@"13"]) {
            [self loadMThaiWebVideo];
        }
        else if ([self.episode.srcType isEqualToString:@"14"]) {
            [self loadMThaiWebVideo];
        }
        else if ([self.episode.srcType isEqualToString:@"15"]) {
            [self loadMThaiWebVideoWithPassword:self.episode.password];
        }
    }
    else if (self.videoUrl) {
        [self openWithVideoUrl:self.videoUrl];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Video not support"];
    }
    
    [self sendTracker];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
}

- (void)sendTracker
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"VideoPlayer"];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:self.episode.Id
                                                      forKey:[GAIFields customDimensionForIndex:3]] build]];
}





- (IBAction)nextButtonTouched:(id)sender {
    if (_idx+1 < self.episode.videos.count) {
        _idx = _idx+1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.episode) {
            if (self.episode.videos.count != 1 ){
                NSString *partInfo = [NSString stringWithFormat:@"Part %d/%d", (_idx + 1), self.episode.videos.count ];
                
                self.partInfoBarButtonItem.title = partInfo;
            }
            
            
            _videoId = self.episode.videos[self.idx];
            
            if ([self.episode.srcType isEqualToString:@"0"]) {
                [self openWithYoutube];
            }
            else if ([self.episode.srcType isEqualToString:@"1"]) {
                [self openWithDailymotion];
            }
            else if ([self.episode.srcType isEqualToString:@"11"]) {
                [self openWebSite:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"12"]) {
                [self openWithVideoUrl:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"13"]) {
                [self loadMThaiWebVideo];
            }
            else if ([self.episode.srcType isEqualToString:@"14"]) {
                [self loadMThaiWebVideo];
            }
            else if ([self.episode.srcType isEqualToString:@"15"]) {
                [self loadMThaiWebVideoWithPassword:self.episode.password];
            }
        }
        else if (self.videoUrl) {
            [self openWithVideoUrl:self.videoUrl];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
   
    }
}
- (IBAction)previousButtonTouched:(id)sender {
    if (_idx >= 1) {
        _idx = _idx-1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.episode) {
            if (self.episode.videos.count != 1 ){
                NSString *partInfo = [NSString stringWithFormat:@"Part %d/%d", (_idx + 1), self.episode.videos.count ];
                
                self.partInfoBarButtonItem.title = partInfo;
            }
            
            
            _videoId = self.episode.videos[self.idx];
            
            if ([self.episode.srcType isEqualToString:@"0"]) {
                [self openWithYoutube];
            }
            else if ([self.episode.srcType isEqualToString:@"1"]) {
                [self openWithDailymotion];
            }
            else if ([self.episode.srcType isEqualToString:@"11"]) {
                [self openWebSite:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"12"]) {
                [self openWithVideoUrl:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"13"]) {
                [self loadMThaiWebVideo];
            }
            else if ([self.episode.srcType isEqualToString:@"14"]) {
                [self loadMThaiWebVideo];
            }
            else if ([self.episode.srcType isEqualToString:@"15"]) {
                [self loadMThaiWebVideoWithPassword:self.episode.password];
            }
        }
        else if (self.videoUrl) {
            [self openWithVideoUrl:self.videoUrl];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        
    }
    
}

- (void)openWebSite:(NSString *)stringUrl {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]]];
    [SVProgressHUD dismiss];
}


#pragma mark - Youtube

- (void)openWithYoutube {
    BOOL isWeb = [[NSUserDefaults standardUserDefaults] boolForKey:kYoutubeWeb];
//    [self switchYoutube:isWeb];
    [self playVideoWithId:_videoId];
    [SVProgressHUD dismiss];
}

- (void)switchYoutube:(BOOL)isWeb
{
    NSString *toggleText;
    if (isWeb)
    {
        [self openWithYoutubeWeb];
        toggleText = @"Embed";
    }
    else
    {
        [self openWithYoutubeEmbed];
        toggleText = @"Web";
    }
    
    UIBarButtonItem *youtubeButton = [[UIBarButtonItem alloc] initWithTitle:toggleText style:UIBarButtonItemStylePlain target:self action:@selector(toggleYoutube:)];
    [self.navigationItem setRightBarButtonItems:@[youtubeButton] animated:YES];
    
}

- (void)toggleYoutube:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isWeb = [userDefaults boolForKey:kYoutubeWeb];
    isWeb = !isWeb;
    [userDefaults setBool:isWeb forKey:kYoutubeWeb];
    [userDefaults synchronize];
    
    [self switchYoutube:isWeb];
}


static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

- (void)playVideoWithId:(NSString *)videoId {
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, _size.width, _size.height, videoId];
    
    [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)openWithYoutubeWeb
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]]]];

}



- (void)openWithYoutubeEmbed
{
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
    <body style=\"margin-top:%@;margin-left:0px\">\
    <div align=\"center\"><object width=\"%0.0f\" height=\"%0.0f\">\
    <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/v/%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </object></div></body></html>";
    
    NSString *html = [NSString stringWithFormat:htmlString,
                      _size.width,
                      _spaceTop,
                      _size.width,
                      _size.height,
                      _videoId,
                      _videoId,
                      _size.width,
                      _size.height];
    
    NSURL *youtubeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]];
    [self.webView loadHTMLString:html baseURL:youtubeUrl];

}

#pragma mark - DailyMotion

- (void)openWithDailymotion {
    BOOL isWeb = [[NSUserDefaults standardUserDefaults] boolForKey:kDailyMotionWeb];
    [self switchDailymotion:isWeb];
    [SVProgressHUD dismiss];
}

- (void)switchDailymotion:(BOOL)isWeb
{
    NSString *toggleText;
    if (isWeb)
    {
        [self openWithDailymotionWeb];
        toggleText = @"Embed";
    }
    else
    {
        [self openWithDailymotionEmbed];
        toggleText = @"Web";
    }
    
    UIBarButtonItem *dmButton = [[UIBarButtonItem alloc] initWithTitle:toggleText style:UIBarButtonItemStylePlain target:self action:@selector(toggleDailymotion:)];
    [self.navigationItem setRightBarButtonItems:@[dmButton] animated:YES];
}

- (void)openWithDailymotionWeb
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]]];

}

- (void)toggleDailymotion:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isWeb = [userDefaults boolForKey:kDailyMotionWeb];
    isWeb = !isWeb;
    [userDefaults setBool:isWeb forKey:kDailyMotionWeb];
    [userDefaults synchronize];
    
    [self switchDailymotion:isWeb];
}

- (void)openWithDailymotionEmbed {
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            <div align=\"center\"><iframe src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </div></body></html>", _size.width, _videoId, _size.width, _size.height];
    
    [self.webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
 
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
                      [self.episode videoThumbnail:_idx],
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
    [SVProgressHUD dismiss];

}

- (void) loadMThaiWebVideo {
    
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:[self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]
             forHTTPHeaderField:@"User-Agent"];
    manager.requestSerializer = requestSerializer;
    
    [manager POST:[NSString stringWithFormat:@"http://video.mthai.com/cool/player/%@.html",_videoId]
       parameters:@{@"clip_password": password}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", string);
        [self startMThaiVideoFromData:responseObject];
         [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
        [SVProgressHUD dismiss];
    }];

}

- (void) startMThaiVideoFromData:(NSData *)data {
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

//- (IBAction)playVideo:(id)sender
//{
//    DLog(@"videoUrl : %@", _videoFile);
//
//    NSURL *urlVideo = [NSURL URLWithString: _videoFile];
//    [[UIApplication sharedApplication] openURL: urlVideo];
//
//    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrl]];
//    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
//    
//    NSURL *assetURL = [NSURL URLWithString:_videoFile];
//    MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:assetURL];
//    [self presentMoviePlayerViewControllerAnimated:movie];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:movie];
//}
//
//- (IBAction)myMovieFinishedCallback:(id)sender
//{
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ( _idx == self.episode.videos.count - 1 ) {
        self.nextBarButtonItem.enabled = NO;
    }else{
        self.nextBarButtonItem.enabled = YES;
    }
}


@end
