//
//  PartListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "PartListViewController.h"
#import "Episode.h"
#import "PartTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VideoPlayerViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface PartListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PartListViewController

static NSString *cellIdentifier = @"PartCellIndentifier";
static NSString *showYoutubePlayerSegue = @"ShowYoutubePlayerSegue";

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = self.episode.titleDisplay;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Favorite"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.episode.videos.count;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Part %d", (section +1)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *imageUrl = [self.episode videoThumbnail:indexPath.section];
    
//    cell = [[PartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    [cell.imageThumbView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    UIImageView *partImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [partImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell addSubview:partImageView];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showYoutubePlayerSegue sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showYoutubePlayerSegue]) {
        VideoPlayerViewController *youtubePlayer = segue.destinationViewController;
        youtubePlayer.episode = self.episode;
        NSIndexPath *idx = (NSIndexPath *)sender;
        youtubePlayer.idx = idx.section;
    }
}



@end
