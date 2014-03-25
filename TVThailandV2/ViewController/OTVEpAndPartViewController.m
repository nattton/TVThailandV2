//
//  OTVEpAndPartViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpAndPartViewController.h"
#import "OTVEpisode.h"
#import "OTVCategory.h"
#import "OTVShow.h"

#import "SVProgressHUD.h"

#import "OTVEpAndPartTableViewCell.h"
#import "OTVMoreDetailViewController.h"
#import "OTVVideoPlayerViewController.h"

@interface OTVEpAndPartViewController () <UITableViewDataSource, UITableViewDelegate, OTVEpAndPartTableViewCellDelegate>

@end

@implementation OTVEpAndPartViewController {
    UIButton *buttonInfoBar;
    NSArray *_otvEpisodes;
    BOOL isLoading;
    BOOL isEnding;
    BOOL isInViewDidAppear;
    OTVEpisode *_otvEpisode;
}


static NSString *cellname = @"cell";
static NSString *otvEpAndPartToShowPlayerSegue = @"OTVEpAndPartToShowPlayerSegue";
static NSString *showDetailSegue = @"ShowDetailSegue";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self calulateUI];
    [self setUpTableFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self calulateUI];
    [self setUpTableFrame];
    [portable reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (isInViewDidAppear) {
        [self setUpTableFrame];
        [portable reloadData];
    }
    isInViewDidAppear = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    buttonInfoBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonInfoBar setImage:[UIImage imageNamed:@"icb_info"] forState:UIControlStateNormal];
    [buttonInfoBar addTarget:self action:@selector(infoButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [buttonInfoBar setFrame:CGRectMake(0, 0, 30, 30)];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonInfoBar];
    
    
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:infoBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonArray;
    
    
    portable = [[UITableView alloc] init];
    [portable setBackgroundColor:[UIColor clearColor]];
    [portable setSeparatorColor:[UIColor clearColor]];
    
    [self setUpTableFrame];
    [portable setDelegate:self];
    [portable setDataSource:self];
    
    [self.view addSubview:portable];
    
//    _refreshControl = [[UIRefreshControl alloc] init];
//    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
//    [portable addSubview:_refreshControl];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)reload {
    isEnding = NO;
    [self reload:0];
}



- (void)reload:(NSUInteger)start {
    if (isLoading || isEnding) {
        return;
    }
    
    isLoading = YES;
    if ([self.otvCategory.IdCate isEqualToString:kOTV_CH7]) {
        [OTVEpisode loadOTVEpisodeAndPartOfCH7:self.otvCategory.cateName showID:self.otvShow.idShow start:start Block:^(NSArray *tempOtvEpisodes, NSError *error) {
            
            if ([tempOtvEpisodes count] == 0) {
                isEnding = YES;
            }
            
            if (start == 0) {
                [SVProgressHUD dismiss];
                
                _otvEpisodes = tempOtvEpisodes;
                
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_otvEpisodes];
                [mergeArray addObjectsFromArray:tempOtvEpisodes];
                _otvEpisodes = [NSArray arrayWithArray:mergeArray];
            }
            
            [portable reloadData];
            isLoading = NO;
            
            
            //        [_refreshControl endRefreshing];
            //        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            
        }];
        
    } else {
        [OTVEpisode loadOTVEpisodeAndPart:self.otvCategory.cateName showID:self.otvShow.idShow start:start Block:^(NSArray *tempOtvEpisodes, NSError *error) {
            
            if ([tempOtvEpisodes count] == 0) {
                isEnding = YES;
            }
            
            if (start == 0) {
                [SVProgressHUD dismiss];
                
                _otvEpisodes = tempOtvEpisodes;
                
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_otvEpisodes];
                [mergeArray addObjectsFromArray:tempOtvEpisodes];
                _otvEpisodes = [NSArray arrayWithArray:mergeArray];
            }
            
            [portable reloadData];
            isLoading = NO;
            
            
            //        [_refreshControl endRefreshing];
            //        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            
        }];
    }

}

- (void) setUpTableFrame {
    
    CGRect newFrame  = self.view.frame;
    CGSize actualSize = self.view.frame.size;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            /* iPAD */
            
            portable.frame = CGRectMake(0, 64, actualSize.width, actualSize.height-120);
//            titleLabel.frame = CGRectMake(0, 153, self.view.frame.size.width, 30);
            
        } else {
            /* iPhone */
            
            if(isPortrait)
            {
                portable.frame = CGRectMake(0, 64, actualSize.width, actualSize.height-110);
//                titleLabel.frame = CGRectMake(0, 113, self.view.frame.size.width, 30);
            }
            else
            {
                portable.frame = CGRectMake(0, 52, actualSize.width, actualSize.height-100);
//                titleLabel.frame = CGRectMake(0, 101, self.view.frame.size.width, 30);
            }
            
        }
        
        
    } else {
        /** OS < 7 **/
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            /* iPAD */
            
            portable.frame = CGRectMake(0, 0, actualSize.width, actualSize.height);
//            titleLabel.frame = CGRectMake(0, 88, self.view.frame.size.width, 30);
            
        } else {
            /* iPhone */
            
            portable.frame = CGRectMake(0, 0, actualSize.width, actualSize.height);
//            titleLabel.frame = CGRectMake(0, 48, self.view.frame.size.width, 30);
            
        }
    }
    
    
    
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _otvEpisodes.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    /* Create custom view to display section header... */
    
    UIImageView *epScrType = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    [epScrType setImage:[UIImage imageNamed:@"ic_player"]];
    [view addSubview:epScrType];
    
    
    UILabel *epTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, tableView.frame.size.width - 50, 18)];
    [epTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *epTitleString = [_otvEpisodes[section] nameTh];
    [epTitleLabel setText:epTitleString];
    [epTitleLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epTitleLabel];
    
    UILabel *epUpdateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 19, tableView.frame.size.width - 70, 12)];
    [epUpdateTimeLabel setFont:[UIFont systemFontOfSize:10]];
    NSString *epUpdateTimeString = [NSString stringWithFormat:@"%@", [_otvEpisodes[section] date]];
    [epUpdateTimeLabel setText:epUpdateTimeString];
    [epUpdateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epUpdateTimeLabel];
    
    [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]]; //your background color...
    
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    OTVEpAndPartTableViewCell *cell = (OTVEpAndPartTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellname];
    
    
    cell = [[OTVEpAndPartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [cell configureWithEpisode:_otvEpisodes[indexPath.section]];
    
//    if ((indexPath.section + 5) == _otvEpisodes.count) {
//        
//        [self reload:_otvEpisodes.count];
//        
//    }
    
    cell.delegate = self;
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


- (IBAction)infoButtonTapped:(id)sender {
    [self performSegueWithIdentifier:showDetailSegue sender:self.otvShow];
}

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(OTVEpisode *)episode{
    
    _otvEpisode = episode;

    [self performSegueWithIdentifier:otvEpAndPartToShowPlayerSegue sender:indexPath];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:otvEpAndPartToShowPlayerSegue]) {
        OTVVideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.otvCategory = _otvCategory;
        videoPlayer.otvEpisode = _otvEpisode;
        NSIndexPath *idx = (NSIndexPath *)sender;
        videoPlayer.idx = idx.row;
        
//        [self.otvEpisode sendViewEpisode];
    }
    
    if ([segue.identifier isEqualToString:showDetailSegue]) {
        OTVMoreDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.otvShow = sender;
    }
}



@end
