//
//  SettingViewController.m
//  TVThailandV2
//
//  Created by April Smith on 7/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "SettingViewController.h"
#import <SVWebViewController/SVWebViewController.h>

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingViewController

/** sequence of row **/

const int rowAbout = 0;
const int rowPrivacyPolicy = 1;

static NSString *aboutViewSegue = @"AboutViewSegue";

static NSString *CellIdentifier = @"CellIdentifier";

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == rowAbout) {
        cell.textLabel.text = @"About";
        
    } else if (indexPath.row == rowPrivacyPolicy) {
        cell.textLabel.text = @"Privacy Policy";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
            case rowAbout:
            [self performSegueWithIdentifier:aboutViewSegue sender:nil];
            break;
        case rowPrivacyPolicy:
            [self openPrivacyWeb];
            break;
        default:
            break;
    }
    
}

- (void)openPrivacyWeb {
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:kPrivacyPolicy_URL];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma - mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

@end
