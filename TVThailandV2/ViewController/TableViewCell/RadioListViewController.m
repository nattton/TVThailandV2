//
//  RadioListViewController.m
//  TVThailandV2
//
//  Created by April Smith on 5/23/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Radio.h"
#import "RadioTableViewCell.h"
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RadioListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *togglePlayPause;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioTitleLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableOfRadio;
@property (weak, nonatomic) IBOutlet UIView *radioPlayerView;

@property (strong, nonatomic) AVPlayer *radioPlayer;

@end

@implementation RadioListViewController {
    NSArray *_radioCategories;
    NSArray *_radios;
    Radio *_radioSelected;
    CGRect _frame;
    UIAlertView *alert;
}


//** cell Identifier **//
static NSString *radioCellIdentifier = @"radioCellIdentifier";


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
    
    alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sorry, this station is currently not available." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _frame = CGRectMake(0, 0, 769 , 38);
        
    }
    else
    {
        _frame = CGRectMake(0, 0, 320 , 35);
        
    }
    
    self.tableOfRadio.separatorColor = [UIColor clearColor];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    [self initializeRadioPlayer];
    
    [self refresh];
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
        [self.tableOfRadio reloadData];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //Dismiss
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_radioCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _radioCategories[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_radios[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    RadioTableViewCell *cellOfRadio = [tableView dequeueReusableCellWithIdentifier:radioCellIdentifier];
    cellOfRadio.selectedBackgroundView = selectedBackgroundViewForCell;
    
    if ( _radios[indexPath.section] && [_radios[indexPath.section] count] > 0) {
        [cellOfRadio configureWithRadio:_radios[indexPath.section][indexPath.row]];
    }
    
    return  cellOfRadio;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    _radioSelected = _radios[indexPath.section][indexPath.row];
    [self.radioTitleLabel setText:_radioSelected.title];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:_radioSelected.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (_radioSelected.radioUrl == nil || [_radioSelected.radioUrl length] == 0 )  {
        [alert show];
    } else {
        AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_radioSelected.radioUrl]];
        [self.radioPlayer replaceCurrentItemWithPlayerItem:currentItem];
        [self.radioPlayer play];
        [self.togglePlayPause setSelected:YES];
    }
    
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - IBAction

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



@end
