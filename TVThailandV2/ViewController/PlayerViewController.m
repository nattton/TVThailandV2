//
//  YouTubeViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "PlayerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import "HTMLParser.h"

#import "Episode.h"
#import "Show.h"
#import "VideoPartTableViewCell.h"

@interface PlayerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTopSpace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopSpace;

@end

@implementation PlayerViewController {
    NSString *_videoId;
    CGSize _size;
}

#pragma mark - Staic Variable
static NSString *videoPartCell = @"videoPartCell";

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
    [self initVideoPlayer:_idx sectionOfVideo:0];

    

    [self setUpOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)setUpOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            self.videoContainerTopSpace.constant = 0.0f;
            self.videoContainerWidth.constant = 700.0f;
            self.videoContainerHeight.constant = 390.0f;
            self.tableViewLeftSpace.constant = 0.0f;
            self.tableViewTopSpace.constant = self.videoContainerWidth.constant + 15.f;
        } else {
            self.videoContainerTopSpace.constant = -22.0f;
            self.videoContainerWidth.constant = 768.0f;
            self.videoContainerHeight.constant = 470.0f;
            self.tableViewLeftSpace.constant = 608.0f;
            self.tableViewTopSpace.constant = 15.f;
        }
    } else {
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            [self.videoPlayerViewController.moviePlayer setFullscreen:YES animated:YES];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setUpOrientation:toInterfaceOrientation];
}


- (void) initLableContainner {
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
        
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

- (void) initVideoPlayer:(long)row sectionOfVideo:(long)section {
    
    self.showNameLabel.text = self.show.title;
    
    
 
    if (section == 0) {
        
        if (self.episode) {
            if ([self.episode.videos count] == 1||[self.episode.videos count] == 0) {
                self.partNameLabel.hidden = YES;
            } else {
                self.partNameLabel.hidden = NO;
            }
            
            _videoId = self.episode.videos[row];
            self.episodeNameLabel.text = self.episode.titleDisplay;
            self.viewCountLabel.text = self.episode.viewCount;
            self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (row + 1), self.episode.videos.count ];
            
            NSLog(@"srcTYPE=%@", self.episode.srcType);
            NSLog(@"_videoId=%@", _videoId);
            
            if ([self.episode.srcType isEqualToString:@"0"]) {
                self.webView.hidden = YES;
                [self openWithYoutubePlayerEmbed:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"1"]) {
                self.webView.hidden = NO;
                [self openWithDailymotionEmbed];
            }
            else if ([self.episode.srcType isEqualToString:@"11"]) {
                self.webView.hidden = NO;
                [self openWebSite:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"12"]) {
                self.webView.hidden = NO;
                [self openWithVideoUrl:_videoId];
            }
            else if ([self.episode.srcType isEqualToString:@"14"]) {
                self.webView.hidden = NO;
                [self loadMThaiWebVideo];
            }
            else if ([self.episode.srcType isEqualToString:@"15"]) {
                self.webView.hidden = NO;
                [self loadMThaiWebVideoWithPassword:self.episode.password];
            }

            
        }

    } else {
        if (self.otherEpisode) {
            if ([self.otherEpisode.videos count] == 1||[self.otherEpisode.videos count] == 0) {
                self.partNameLabel.hidden = YES;
            } else {
                self.partNameLabel.hidden = NO;
            }
            
            _videoId = self.otherEpisode.videos[row];
            self.episodeNameLabel.text = self.otherEpisode.titleDisplay;
            self.viewCountLabel.text = self.otherEpisode.viewCount;
            self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (row + 1), self.otherEpisode.videos.count ];
            
            
            
            if ([self.otherEpisode.srcType isEqualToString:@"0"]) {
                self.webView.hidden = YES;
                [self openWithYoutubePlayerEmbed:_videoId];
            }
            else if ([self.otherEpisode.srcType isEqualToString:@"1"]) {
                self.webView.hidden = NO;
                [self openWithDailymotionEmbed];
            }
            else if ([self.otherEpisode.srcType isEqualToString:@"11"]) {
                self.webView.hidden = NO;
                [self openWebSite:_videoId];
            }
            else if ([self.otherEpisode.srcType isEqualToString:@"12"]) {
                self.webView.hidden = NO;
                [self openWithVideoUrl:_videoId];
            }
            else if ([self.otherEpisode.srcType isEqualToString:@"14"]) {
                self.webView.hidden = NO;
                [self loadMThaiWebVideo];
            }
            else if ([self.otherEpisode.srcType isEqualToString:@"15"]) {
                self.webView.hidden = NO;
                [self loadMThaiWebVideoWithPassword:self.episode.password];
            }

        }
    }



    
    
    [self setSelectedPositionOfVideoPartAtRow:row section:section];
    
}

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
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            <div align=\"center\"><iframe src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </div></body></html>", _size.width, _videoId, _size.width, _size.height];
    
    [self.webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
  
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





- (void) setSelectedPositionOfVideoPartAtRow:(long)row section:(long)section {
    NSIndexPath *indexPathOfVideoPart=[NSIndexPath indexPathForRow:row inSection:section];
    [self.tableOfVideoPart selectRowAtIndexPath: indexPathOfVideoPart
                                       animated:YES
                                 scrollPosition:UITableViewScrollPositionMiddle];
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(long)section {

    if (section == 0) {
        return [self.episode.videos count];
    } else if (section == 1){
        return [self.otherEpisode.videos count];
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    VideoPartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:videoPartCell];
    cell.selectedBackgroundView = selectedBackgroundViewForCell;
    
    if (indexPath.section == 0) {
        [cell configureWithVideoPart:self.episode partNumber:indexPath.row+1];
    } else if (indexPath.section == 1){
        [cell configureWithVideoPart:self.otherEpisode partNumber:indexPath.row+1];

    }

    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 

    [self initVideoPlayer:indexPath.row sectionOfVideo:indexPath.section];
    

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Other videos";
    }
    
    return @"";
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 35;
    }
}

@end
