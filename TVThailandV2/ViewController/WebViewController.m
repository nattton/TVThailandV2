//
//  WebViewController.m
//  TVThailandV2
//
//  Created by April Smith on 6/24/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openWebSiteUrl:self.stringUrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public Method

- (void)openWebSiteUrl:(NSString *)stringUrl {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]]];
}

#pragma mark - IBAction

- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)canRotate { }

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
