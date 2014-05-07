//
//  HomeContentViewController.m
//  TVThailandV2
//
//  Created by April Smith on 4/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "HomeContentViewController.h"

@interface HomeContentViewController ()

@end

@implementation HomeContentViewController




- (void)viewDidLoad
{

    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        DLog(@"Load resources for iOS 6.1 or earlier");
        
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    }
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
