//
//  ShowListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowListViewController.h"
#import "ShowTableViewCell.h"
#import "Show.h"

#import "GenreListViewController.h"
#import "EpisodeListViewController.h"

@interface ShowListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowListViewController {
    NSArray *_shows;
    NSString *_Id;
    ShowModeType _mode;
    bool isLoading;
    UIRefreshControl *_refreshControl;
}

#pragma mark - Static Variable

static NSString *cellIdentifier = @"ShowCellIdentifier";
static NSString *showGenreSegue = @"ShowGenreSegue";
static NSString *showEpisodeSegue = @"ShowEpisodeSegue";

#pragma mark - Seque Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showGenreSegue]) {
        GenreListViewController *genreListViewController = segue.destinationViewController;
        genreListViewController.showListViewController = self;
    } else if ([segue.identifier isEqualToString:showEpisodeSegue]) {
        Show *show = (Show *)sender;
        EpisodeListViewController *episodeListViewController = segue.destinationViewController;
        episodeListViewController.show = show;
    }
}

#pragma mark - UIViewController

- (id)init {
    self = [super init];
    if (self) {
        _mode = kWhatsNew;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl beginRefreshing];
    
    [self reload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Function

- (void)reload {
    [self reload:0];
}

- (void)reloadWithMode:(ShowModeType) mode Id:(NSString *)Id {
    _shows = [NSArray array];
    [self.tableView reloadData];
    _mode = mode;
    _Id = Id;
    [self reload];
}

- (void)reload:(NSUInteger)start {
    if (isLoading) {
        return;
    }
    isLoading = YES;
    if (_mode == kWhatsNew) {
        [Show loadWhatsNewDataWithStart:start Block:^(NSArray *tempShows, NSError *error) {
            if (start == 0) {
                _shows = tempShows;
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:tempShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            [self.tableView reloadData];
            isLoading = NO;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        }];
    } else if (_mode == kGenre) {
        [Show loadGenreDataWithId:_Id Start:start Block:^(NSArray *tempShows, NSError *error) {
            if (start == 0) {
                _shows = tempShows;
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:tempShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            [self.tableView reloadData];
            isLoading = NO;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        }];
    }
    
    if (start == 0) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}


#pragma mark - Table Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (_mode == kWhatsNew) {
        [cell configureWhatsNewWithShow:_shows[indexPath.row]];
    } else if (_mode == kGenre) {
        [cell configureGenreWithShow:_shows[indexPath.row]];
    }
    
    if ((indexPath.row + 5) == _shows.count) {
        [self reload:_shows.count];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showEpisodeSegue sender:_shows[indexPath.row]];
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

@end
