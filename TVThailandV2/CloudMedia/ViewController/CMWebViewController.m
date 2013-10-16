//
//  CMWebViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/7/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMWebViewController.h"
#import "CMUser.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"

@interface CMWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CMWebViewController

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
    CMUser *cmUser = [CMUser sharedInstance];
    NSString *path = [NSString stringWithFormat:@"http://www.cloudmediathai.com/tv/topup.zul?userName=%@&memberId=%@", cmUser.userName,cmUser.memberId];
//	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.video.videoURL]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tabOnCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
