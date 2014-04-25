//
//  ChannelViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ChannelViewController.h"
#import "Channel.h"
#import "ShowListViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "VideoPlayerViewController.h"

@interface ChannelViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation ChannelViewController {
    NSArray *_channels;
    UIAlertView *alert;
    Channel *channelSelected;
}

static NSString *cellIdentifier = @"ChannelCellIdentifier";
static NSString *showListSegue = @"ShowListSegue";
static NSString *showPlayerSegue = @"ShowPlayerSegue";

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
    
      alert = [[UIAlertView alloc] initWithTitle:@"เลือกรายการ" message:@"" delegate:self cancelButtonTitle:@"ดูย้อนหลัง" otherButtonTitles:@"ดูสด", nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        DLog(@"Load resources for iOS 6.1 or earlier");
//        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//    } else {
//        DLog(@"Load resources for iOS 7 or later");
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.7];
//        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//    }

    [self refresh];
}

- (IBAction)refreshButtonTapped:(id)sender {
    [self refresh];
}

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [Channel loadData:^(NSArray *channels, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        _channels = channels;
        [self.collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _channels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Channel *ch = _channels[indexPath.row];
    
    UIImageView *channelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [channelImageView setImageWithURL:[NSURL URLWithString:ch.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell addSubview:channelImageView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 100, 20)];
    titleLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = ch.title;
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [cell addSubview:titleLabel];
    
    UILabel *liveLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 20, 10)];
    liveLabel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    liveLabel.textColor = [UIColor whiteColor];
    liveLabel.text = @"LIVE";
    liveLabel.textAlignment = NSTextAlignmentCenter;
    [liveLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:7]];
    [cell addSubview:liveLabel];
    
    if (ch.videoUrl == nil || [ch.videoUrl length] == 0) {
        liveLabel.hidden = YES;
    }
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     channelSelected = _channels[indexPath.row];
    NSLog(@"channelSelected.isHasEp:%@",channelSelected.isHasEp);
        if (channelSelected.videoUrl == nil || [channelSelected.videoUrl length] == 0) {
            [self performSegueWithIdentifier:showListSegue sender:channelSelected];
        } else {
            if ([channelSelected.isHasEp  isEqual: @"1"]) {
                [alert show];
            } else {
                [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
            }

            
        }
    
    
    }

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //Watch on demand program
        [self performSegueWithIdentifier:showListSegue sender:channelSelected];
    }
    if (buttonIndex == 1) {
        //Watch on LIVE program
        [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];

    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showListSegue]) {
        ShowListViewController *showListViewController = segue.destinationViewController;
        if (sender) {
            Channel *channel = (Channel *)sender;
            showListViewController.navigationItem.title = channel.title;
            showListViewController.videoUrl = channel.videoUrl;
            [showListViewController reloadWithMode:kChannel Id:channel.Id];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName
                   value:@"Channel"];
            [tracker send:[[[GAIDictionaryBuilder createAppView] set:channel.title
                                                              forKey:[GAIFields customDimensionForIndex:5]] build]];
        }
    }
    
    if ([segue.identifier isEqual:showPlayerSegue]) {
        VideoPlayerViewController *videoPlayerViewController = segue.destinationViewController;
        if (sender) {
            Channel *channel = (Channel *)sender;
            videoPlayerViewController.videoUrl = channel.videoUrl;
            videoPlayerViewController.isHidenToolbarPlayer = YES;
            videoPlayerViewController.navigationItem.title = [NSString stringWithFormat:@"Live : %@", channel.title];
        }
    }
    
}

@end
