//
//  CMVideoPlayerViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMVideoPlayerViewController.h"
#import "CMEpisode.h"
#import "CMMovie.h"

@interface CMVideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CMVideoPlayerViewController{
    CGSize _size;
}

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
	self.navigationItem.title = self.cmEpisode.thaiName;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
    }
    else
    {
        _size = CGSizeMake(320, 240);
    }
    if (self.cmEpisode !=  nil) {
        if (_videomode == kEPPlay) {
            NSLog(@"Episode Play");
            [self openWithVideoUrl:self.cmEpisode.videoLink];
        }else if(_videomode == kEPPreview){
            NSLog(@"Episode Preview");
            [self openWithYoutube:self.cmEpisode.trailerLink];
        }

    }

    if (self.cmMovie != nil && _videomode == kMoviePreview){
        NSLog(@"Movie Preview");
        [self openWithYoutube:self.cmMovie.trailerLink];
        
    }
    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.video.videoURL]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                      @"",
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    
    
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
}

- (void)openWithYoutube:(NSString *)videoUrl{

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoUrl]]];
}


@end
