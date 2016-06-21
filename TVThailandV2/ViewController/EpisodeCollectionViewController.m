//
//  EpisodeViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 12/11/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodeCollectionViewController.h"

#import "SVProgressHUD.h"
#import "Show.h"
#import "Episode.h"

@interface EpisodeCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation EpisodeCollectionViewController {
    NSArray *_episodes;
    long _currentEpIndex;
    BOOL _isLoading;
    BOOL _isEnding;
    UIRefreshControl *_refreshControl;
    
    UIButton *_buttonFavBar;
    UIButton *_buttonInfoBar;
}

static NSString *cellIdentifier = @"EpisodeViewCellIdentifier";

- (void)viewDidLoad {
    [self reload];
}

- (void)reload {
    _isEnding = NO;
    [self reload:0];
}


- (void)reload:(NSUInteger)start {
    if (_isLoading || _isEnding) {
        return;
    }
    
    _isLoading = YES;
    [Episode retrieveDataWithId:self.show Start:start Block:^(Show *show, NSArray *tempEpisodes, NSError *error) {
        if (show) {
            self.show = show;
            self.show.isOTV = NO;
        }
        
        if ([tempEpisodes count] == 0) {
            _isEnding = YES;
        }
        
        if (start == 0) {
            [SVProgressHUD dismiss];
            _episodes = tempEpisodes;
        } else {
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_episodes];
            [mergeArray addObjectsFromArray:tempEpisodes];
            _episodes = [NSArray arrayWithArray:mergeArray];
        }
        
//        [self.portTableView reloadData];
        _isLoading = NO;
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        
//        self.noContentLabel.hidden = _episodes.count > 0;
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
