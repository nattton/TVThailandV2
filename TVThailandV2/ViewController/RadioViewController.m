//
//  RadioViewController.m
//  TVThailandV2
//
//  Created by April Smith on 5/15/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioViewController.h"
#import "SVProgressHUD.h"
#import "Radio.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RadioViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation RadioViewController {
    NSArray *_radioes;
    Radio *radioSelected;
    
}

static NSString *cellIdentifier = @"RadioCellIdentifier";

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
    
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];

    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButtonTapped:(id)sender {
    [self refresh];
}

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [Radio loadData:^(NSArray *radioes, NSError *error) {
        
        [SVProgressHUD dismiss];
//        NSLog(@"Radioes: %@",radioes);
        _radioes = radioes;
        [self.collectionView reloadData];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Radio *rd = _radioes[indexPath.row];
    
    UIImageView *radioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [radioImageView setImageWithURL:[NSURL URLWithString:rd.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [cell addSubview:radioImageView];
    
    
    UIView *labelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 100, 20)];
    labelBackgroundView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    [cell addSubview:labelBackgroundView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 90, 20)];
    titleLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = rd.title;
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [cell addSubview:titleLabel];
    
    
    return cell;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _radioes.count;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    radioSelected = _radioes[indexPath.row];

//    if (channelSelected.videoUrl == nil || [channelSelected.videoUrl length] == 0) {
//        [self performSegueWithIdentifier:showListSegue sender:channelSelected];
//    } else {
//        if ([channelSelected.isHasEp  isEqual: @"1"]) {
//            [alert show];
//        } else {
//            [self performSegueWithIdentifier:showPlayerSegue sender:channelSelected];
//        }
//        
//        
//    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:showListSegue]) {
//        ShowListViewController *showListViewController = segue.destinationViewController;
//        if (sender) {
//            Channel *channel = (Channel *)sender;
//            showListViewController.navigationItem.title = channel.title;
//            showListViewController.videoUrl = channel.videoUrl;
//            [showListViewController reloadWithMode:kChannel Id:channel.Id];
//            
//            id tracker = [[GAI sharedInstance] defaultTracker];
//            [tracker set:kGAIScreenName
//                   value:@"Channel"];
//            [tracker send:[[[GAIDictionaryBuilder createAppView] set:channel.title
//                                                              forKey:[GAIFields customDimensionForIndex:5]] build]];
//        }
//    }
//    
//    if ([segue.identifier isEqual:showPlayerSegue]) {
//        VideoPlayerViewController *videoPlayerViewController = segue.destinationViewController;
//        if (sender) {
//            Channel *channel = (Channel *)sender;
//            videoPlayerViewController.videoUrl = channel.videoUrl;
//            videoPlayerViewController.isHidenToolbarPlayer = YES;
//            videoPlayerViewController.navigationItem.title = [NSString stringWithFormat:@"Live : %@", channel.title];
//        }
//    }
    
}

@end
