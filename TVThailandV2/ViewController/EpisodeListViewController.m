//
//  EpisodeListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodeListViewController.h"
#import "Show.h"
#import "Episode.h"
#import "EpisodeTableViewCell.h"
#import "PartListViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface EpisodeListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation EpisodeListViewController {
    NSArray *_episodes;
}

static NSString *cellIndentifier = @"EpisodeCellIdentifier";
static NSString *showPartSegue = @"ShowPartSegue";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showPartSegue]) {
        PartListViewController *partListViewController = segue.destinationViewController;
        partListViewController.episode = (Episode *)sender;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.show.title;
    
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:self.show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder40"]];
	
    [Episode loadEpisodeDataWithId:self.show.Id Start:0 Block:^(Show *show, NSArray *episodes, NSError *error) {
        _episodes = episodes;
        
        if (show) {
            self.show = show;
        }
        
        [self.tableView reloadData];
        
    }];
}

- (void)loadData {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    [cell configureWithEpisode:_episodes[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showPartSegue sender:_episodes[indexPath.row]];
}


@end
