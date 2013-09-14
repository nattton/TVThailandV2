//
//  YoutubePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "Episode.h"

#import "UserAgent.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "HTMLParser.h"

@interface VideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VideoPlayerViewController {
    NSString *_videoId;
    CGSize _size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
    }
    else
    {
        _size = CGSizeMake(320, 240);
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Part %d", (_idx + 1)];
    _videoId = self.episode.videos[self.idx];
    
    if ([self.episode.srcType isEqualToString:@"0"]) {
        [self openWithYoutube];
    } else if ([self.episode.srcType isEqualToString:@"1"]) {
        [self openWithDailymotion];
    } else if ([self.episode.srcType isEqualToString:@"13"]) {
        [self loadMThaiWebVideo];
    } else if ([self.episode.srcType isEqualToString:@"14"]) {
        [self loadMThaiWebVideo];
    } else if ([self.episode.srcType isEqualToString:@"15"]) {
        [self loadMThaiWebVideoWithPassword:self.episode.password];
    }
}

- (void)openWithYoutube {
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><object width=\"%0.0f\" height=\"%0.0f\">\
    <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/v/%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </object></div></body></html>";
    
    NSString *html = [NSString stringWithFormat:htmlString,
                      _size.width,
                      _size.width,
                      _size.height,
                      _videoId,
                      _videoId,
                      _size.width,
                      _size.height];
    
    NSURL *youtubeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]];
    [self.webView loadHTMLString:html baseURL:youtubeUrl];
}

- (void)openWithDailymotion {
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            <div align=\"center\"><iframe src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </div></body></html>", _size.width, _videoId, _size.width, _size.height];
    
    [self.webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
}

- (void) OpenWithVideoUrl:(NSString *)videoUrl {
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
}

- (void) loadMThaiWebVideo {
    
//    NSURL *urlMThai = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/player.php?id=24M%@M0",_videoId]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://video.mthai.com"]];
    [httpClient setDefaultHeader:@"User-Agent" value:[UserAgent defaultUserAgent]];
    [httpClient getPath:[NSString stringWithFormat:@"player.php?id=24M%@M0",_videoId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self startMThaiVideoFromData:responseObject];
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"str: %@", str);
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void) loadMThaiWebVideoWithPassword:(NSString *)password {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://video.mthai.com"]];
    [httpClient setDefaultHeader:@"User-Agent" value:[UserAgent defaultUserAgent]];
    [httpClient postPath:[NSString stringWithFormat:@"player.php?id=24M%@M0",_videoId] parameters:@{@"clip_password": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self startMThaiVideoFromData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void) startMThaiVideoFromData:(NSData *)data {
    NSError *error = nil;
//    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *sourceNodes = [bodyNode findChildTags:@"source"];
    
    for (HTMLNode *sourceNode in sourceNodes)
    {
        if ([sourceNode getAttributeNamed:@"src"]) {
            NSString *videoUrl = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            if ([videoUrl rangeOfString:_videoId].location != NSNotFound) {
                if ([videoUrl hasSuffix:@"flv"]) {
                    NSLog(@"FLV");
#warning FLV
                    return;
                }else {
                    [self OpenWithVideoUrl:videoUrl];
                }
                return;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
