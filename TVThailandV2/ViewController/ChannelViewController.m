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

@interface ChannelViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation ChannelViewController {
    NSArray *_channels;
}

static NSString *cellIdentifier = @"ChannelCellIdentifier";
static NSString *showListSegue = @"ShowListSegue";

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
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:showListSegue sender:_channels[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showListSegue]) {
        ShowListViewController *showListViewController = segue.destinationViewController;
        if (sender) {
            Channel *selectedChannel = (Channel *)sender;
            showListViewController.navigationItem.title = selectedChannel.title;
            showListViewController.videoUrl = selectedChannel.videoUrl;
            [showListViewController reloadWithMode:kChannel Id:selectedChannel.Id];
        }
    }
}

@end
