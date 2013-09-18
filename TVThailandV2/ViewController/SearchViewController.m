//
//  SearchViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/18/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "SearchViewController.h"
#import "Show.h"
#import "ShowTableViewCell.h"
#import "EpisodeListViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController {
    UISearchBar *_searchBar;
    NSArray *_shows;
}

static NSString *cellIdentifier = @"ShowCellIdentifier";
static NSString *showEpisodeSegue = @"SearchShowEpisodeSegue";

#pragma mark - Seque Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showEpisodeSegue]) {
        Show *show = (Show *)sender;
        EpisodeListViewController *episodeListViewController = segue.destinationViewController;
        episodeListViewController.show = show;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)search:(NSString *)keyword {
    if (![keyword isEqualToString:@""]) {
        [Show loadSearchDataWithKeyword:keyword Block:^(NSArray *tempShows, NSError *error) {
            _shows = tempShows;
            [self.tableView reloadData];
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self search:searchText];
}

#pragma mark - Search

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _shows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureGenreWithShow:_shows[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchBar resignFirstResponder];
    [self performSegueWithIdentifier:showEpisodeSegue sender:_shows[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}


@end
