//
//  RadioViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/27/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Radio.h"
#import "RadioCollectionHeaderView.h"
#import "RadioCollectionViewCell.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface RadioViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIButton *togglePlayPause;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioTitleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *radioPlayerView;

@property (strong, nonatomic) AVPlayer *radioPlayer;

@end

@implementation RadioViewController {
    NSArray *_radioCategories;
    NSArray *_radios;
    Radio *_radioSelected;
    UIAlertView *alert;
}


//** cell Identifier **//
static NSString *radioHeaderIdentifier = @"RadioHeaderView";
static NSString *radioFooterIdentifier = @"RadioFooterView";
static NSString *radioCellIdentifier = @"RadioCollectionViewCell";

#pragma mark - UIViewController Override Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sorry, this station is currently not available." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    [self initializeRadioPlayer];
    
    [self refresh];
    
    [self sendTracker];
}

#pragma mark - Private Method

- (void)sendTracker {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Radio"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)initializeRadioPlayer {
    self.radioPlayer = [[AVPlayer alloc] init];
    self.thumbnailImageView.layer.cornerRadius = 2.0;
    self.thumbnailImageView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [Radio loadData:^(NSArray *radioCategories, NSArray *radios, NSError *error) {
        [SVProgressHUD dismiss];
        _radioCategories = radioCategories;
        _radios = radios;
        [self.collectionView reloadData];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //Dismiss
    }
    
}

#pragma mark - IBAction

- (IBAction)refreshTapped:(id)sender {
    [self refresh];
}

- (IBAction)playPauseTapped:(id)sender {
    if (_radioSelected) {
        if(self.togglePlayPause.selected) {
            [self.radioPlayer pause];
            [self.togglePlayPause setSelected:NO];
        } else {
            [self.radioPlayer play];
            [self.togglePlayPause setSelected:YES];
        }
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_radioCategories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_radios[section] count];
}

#define kFooterHeight 10
#define kLastFooterHeight 100

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if ([_radioCategories count] == section + 1) {
        return CGSizeMake(0, kLastFooterHeight);
    }
    
    return CGSizeMake(0, kFooterHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RadioCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:radioCellIdentifier forIndexPath:indexPath];

    [cell configureWithRadio:_radios[indexPath.section][indexPath.row]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        RadioCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:radioHeaderIdentifier forIndexPath:indexPath];
        
        [headerView.titleLabel setText:_radioCategories[indexPath.section]];
        
        reusableview = headerView;
    }
    else if(kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:radioFooterIdentifier forIndexPath:indexPath];
        
        reusableview = footerView;
    }

    return reusableview;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    bool isChanged = (_radioSelected != _radios[indexPath.section][indexPath.row]);
    _radioSelected = _radios[indexPath.section][indexPath.row];
    [self.radioTitleLabel setText:_radioSelected.title];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:_radioSelected.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (_radioSelected.radioUrl == nil || [_radioSelected.radioUrl length] == 0 )  {
        [alert show];
    } else {
        if (isChanged) {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName
                   value:@"Radio"];
            [tracker send:[[[GAIDictionaryBuilder createAppView] set:_radioSelected.title
                                                              forKey:[GAIFields customDimensionForIndex:6]] build]];
            
            AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_radioSelected.radioUrl]];
            [self.radioPlayer replaceCurrentItemWithPlayerItem:currentItem];
        }
        [self.radioPlayer play];
        [self.togglePlayPause setSelected:YES];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
