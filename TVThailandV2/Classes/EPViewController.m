//
//  EPViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/23/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "EPViewController.h"
#import "EPViewCell.h"
#import "GADBannerView.h"

#import "Three20/Three20.h"
#import "NSString+Utils.h"
#import "UIViewController+VideoPlayer.h"

static NSString *epViewcell = @"EPViewCell";

@interface EPViewController ()
{
    GADBannerView *bannerView;
    NSArray *videoItems;
    NSString *srcType;
    NSString *password;
    BOOL isPad;
}
@end

@implementation EPViewController

@synthesize viewBanner = _viewBanner;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)initializeData
{
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeData];
    
    // Setup AdMob
    
    if (isPad) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPad;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
    }
    
    bannerView.rootViewController = self;
    
    [self.viewBanner addSubview:bannerView];
    
    [bannerView loadRequest:[GADRequest request]];
    
}

- (void)setEPTitle:(NSString *)title  andVideoItems:(NSArray *)videoIdItems andSrcType:(NSString *)src_type andPassword:(NSString *)pwd {
    self.navigationItem.title = title;
    videoItems = videoIdItems;
    srcType = src_type;
    password = pwd;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPViewCell *cell = (EPViewCell *)[tableView dequeueReusableCellWithIdentifier:epViewcell];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]
                                    loadNibNamed:epViewcell owner:nil options:nil];
        for (id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[EPViewCell class]])
            {
                cell = (EPViewCell *)currentObject;
                break;
            }
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.thumbnail.defaultImage = [UIImage imageNamed:@"Icon"];   
    }
    
    // Configure the cell.
    [cell.title setText:[NSString stringWithFormat:@"ช่วงที่ %d / %d", (indexPath.row+1),[videoItems count]]];
    cell.thumbnail.urlPath = [self videoThumbnailWithVideoId:[videoItems objectAtIndex:indexPath.row] andSrcType:srcType];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *videoId = [videoItems objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"ช่วงที่ %d / %d", (indexPath.row+1),[videoItems count]];
    [self openVideoWithTitle:title SrcType:srcType VideoId:videoId Password:password];
}

@end
