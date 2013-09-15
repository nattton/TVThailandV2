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
    BOOL isLoading;
    UIRefreshControl *_refreshControl;
}

static NSString *cellIndentifier = @"EpisodeCellIdentifier";
static NSString *showPartSegue = @"ShowPartSegue";

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
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl beginRefreshing];
    
    [self reload:0];
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
     [self reload:0];
}

- (void)reload:(NSUInteger)start {
    if (isLoading) {
        return;
    }
    
    isLoading = YES;
    [Episode loadEpisodeDataWithId:self.show.Id Start:start Block:^(Show *show, NSArray *tempEpisodes, NSError *error) {
        if (show) {
            self.show = show;
        }
        
        if (start == 0) {
            _episodes = tempEpisodes;
        } else {
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_episodes];
            [mergeArray addObjectsFromArray:tempEpisodes];
            _episodes = [NSArray arrayWithArray:mergeArray];
        }
        
        [self.tableView reloadData];
        isLoading = NO;
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
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
    
    if ((indexPath.row + 5) == _episodes.count) {
        [self reload:_episodes.count];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showPartSegue sender:_episodes[indexPath.row]];
}


@end
