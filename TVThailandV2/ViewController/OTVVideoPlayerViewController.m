//
//  OTVVideoPlayerViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVVideoPlayerViewController.h"
#import "SVProgressHUD.h"
#import "OTVCategory.h"
#import "OTVEpisode.h"
#import "OTVPart.h"

@interface OTVVideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *videoToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *partInfoBarButtonItem;

@end

@implementation OTVVideoPlayerViewController {
    CGSize _size;
    OTVPart *_part;

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
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
    
    _part = [self.otvEpisode.parts objectAtIndex:self.idx];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    
    self.navigationItem.title = self.otvEpisode.nameTh;
    NSString *partInfo = [NSString stringWithFormat:@"%@",[[self.otvEpisode.parts objectAtIndex:self.idx] nameTh]];
    self.partInfoBarButtonItem.title = partInfo;
    
    [self enableOrDisableNextPreviousButton];
    
    if ([self.otvCategory.cateName isEqualToString:kOTV_CH7]) {
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
    [SVProgressHUD dismiss];
}

- (void) openWithIFRAME:(NSString *)iframeText {
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            <iframe src='http://www.bugaboo.tv/embed/110269?w=640&h=360&auto=true&' allowtransparency='true' frameborder='0' width='640' height='360' scrolling='no'></iframe></body></html>", _size.width];
    
    [self.webView loadHTMLString:htmlString
                         baseURL:nil];
    [SVProgressHUD dismiss];
}

- (IBAction)previousButtonTouched:(id)sender {
    if (_idx >= 1) {
        _idx = _idx-1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
            
            _part = [self.otvEpisode.parts objectAtIndex:_idx];
            
            NSString *partInfo = [NSString stringWithFormat:@"%@",[_part nameTh]];
            self.partInfoBarButtonItem.title = partInfo;
            
            if ([self.otvCategory.cateName isEqualToString:kOTV_CH7]) {
                //iFrame
                [self openWithIFRAME:_part.streamURL];
            } else {
                [self openWithVideoUrl:_part.streamURL];
            }

        } else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        
    }
    
}
- (IBAction)nextButtonTouched:(id)sender {
    if (_idx+1 < self.otvEpisode.parts.count) {
        _idx = _idx+1;
        
        [self enableOrDisableNextPreviousButton];
        if (self.otvEpisode.parts) {
            
            _part = [self.otvEpisode.parts objectAtIndex:_idx];
            
            NSString *partInfo = [NSString stringWithFormat:@"%@",[_part nameTh]];
            self.partInfoBarButtonItem.title = partInfo;
            
            if ([self.otvCategory.cateName isEqualToString:kOTV_CH7]) {
                //iFrame
                [self openWithIFRAME:_part.streamURL];
            } else {
                [self openWithVideoUrl:_part.streamURL];
            }
        }

        else
        {
            [SVProgressHUD showErrorWithStatus:@"Video not support"];
        }
        
    }
    
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
