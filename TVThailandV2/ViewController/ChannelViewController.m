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
#import <Google/Analytics.h>

#import "VideoPlayerViewController.h"
#import "ChannelCollectionViewCell.h"

@import GoogleMobileAds;

@interface ChannelViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GADInterstitialDelegate>

@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation ChannelViewController {
    NSArray *_channels;
    Channel *channelSelected;
}

static NSString *cellIdentifier = @"ChannelCellIdentifier";
static NSString *showListSegue = @"ShowListSegue";
static NSString *showPlayerSegue = @"ShowPlayerSegue";

#pragma mark - UIViewController Override Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interstitial = [self createAndLoadInterstitial];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Channel"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Method

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [Channel retrieveData:^(NSArray *channels, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        _channels = channels;
        [self.collectionView reloadData];
    }];
}

#pragma mark - Action

- (IBAction)refreshButtonTapped:(id)sender {
    [self refresh];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _channels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Channel *ch = _channels[indexPath.row];
    
    [cell configureWithChannel:ch];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     channelSelected = _channels[indexPath.row];
    DLog(@"channelSelected.isHasEp:%@", channelSelected.isHasEp);
        if (channelSelected.videoUrl == nil || [channelSelected.videoUrl length] == 0) {
            [self performSegueWithIdentifier:showListSegue sender:channelSelected];
        } else {
            if ([channelSelected.isHasEp  isEqual: @"1"]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"เลือกรายการ" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *selectOnDemand = [UIAlertAction actionWithTitle:@"รายการสด" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
                }];
                [alert addAction:selectOnDemand];
                UIAlertAction *selectLive = [UIAlertAction actionWithTitle:@"ย้อนหลัง" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self performSegueWithIdentifier:showListSegue sender:channelSelected];
                }];
                [alert addAction:selectLive];
                UIAlertAction *selectCancel = [UIAlertAction actionWithTitle:@"ยกเลิก" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:selectCancel];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            } else {
                
                [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
            }
        }
    }


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showListSegue]) {
        ShowListViewController *showListViewController = segue.destinationViewController;
        showListViewController.homeSlideMenuViewController = self.homeSlideMenuViewController;
        
        if (sender) {
            Channel *channel = (Channel *)sender;
            showListViewController.channel = channel;
            [showListViewController reloadWithMode:kChannel Id:channel.Id];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName
                   value:@"Channel"];
            [tracker send:[[[GAIDictionaryBuilder createScreenView] set:channel.title
                                                              forKey:[GAIFields customDimensionForIndex:5]] build]];
        }
    }
    
    if ([segue.identifier isEqual:showPlayerSegue]) {
        VideoPlayerViewController *videoPlayerViewController = segue.destinationViewController;
        if (sender) {
            Channel *channel = (Channel *)sender;
            videoPlayerViewController.channel = channel;
            videoPlayerViewController.channelViewController = self;
        }
    }
    
}

- (void) displayInterstitialAds {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:kAdMobInterstitial];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
//    [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
//    [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
}

@end
