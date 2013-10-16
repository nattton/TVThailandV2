
//  CMEpisodeViewController.m
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMEpisodeViewController.h"
#import "CMMovie.h"
#import "UIImageView+AFNetworking.h"
#import "CMEpisode.h"
#import "CMEpisodeCell.h"
#import "CMVideoPlayerViewController.h"
#import "CMMoreInfoViewController.h"
#import "CMUser.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"
#import "SVProgressHUD.h"

@interface CMEpisodeViewController () <UITableViewDataSource,UITableViewDelegate, CMEpisodeCellDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation CMEpisodeViewController{
    NSArray *_cmEpisode;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
@private
    NSString *EP_MODE;
    
}

static NSString *CMEpisodeCellIdentifier = @"CMEpisodeCellIdentifier";
static NSString *CMPlayVideoSegue = @"CMPlayVideoSegue";
static NSString *CMMoreInfoSegue = @"CMMoreInfoSegue";
static NSString *CMMovieToAccountSegue = @"CMMovieToAccountSegue";


- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD showWithStatus:@"Loading..."];
     NSLog(@"%@",self.cmMovie.thaiName);

    [self reload];
    [self setUpHeader];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
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
- (void) reload:(NSUInteger)start{

    if (isLoading||isEnding) {
        return;
    }
    isLoading = YES;
    
    [CMEpisode loadCMEpWithMovieID:self.cmMovie.idMovie start:start Block:^(NSArray *cmEpisodes, NSError *error) {
        [SVProgressHUD dismiss];
        if ([cmEpisodes count] == 0) {
            isEnding = YES;
        }
        if (start==0) {
            _cmEpisode = cmEpisodes;
        }else{
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_cmEpisode];
            [mergeArray addObjectsFromArray:cmEpisodes];
            _cmEpisode = [NSArray arrayWithArray:mergeArray];
        }
        
        [self.tableView reloadData];
        isLoading = NO;
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cmEpisode.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMEpisodeCell *cell =  [tableView dequeueReusableCellWithIdentifier:CMEpisodeCellIdentifier];
    cell.delegate = self;
    [cell configureWithCMEpisode:_cmEpisode[indexPath.row]];
    
    if ((indexPath.row + 5) == _cmEpisode.count) {
        [self reload:_cmEpisode.count];
    }
    return  cell;
}
- (IBAction)tapOnPreviewMovieButton:(id)sender {
    EP_MODE = @"kMoviePreview";
    [self performSegueWithIdentifier:CMPlayVideoSegue sender:self.cmMovie];
}

- (void)tappedPlayEpisodeButton:(CMEpisode *)episode {
    EP_MODE = @"kEPPlay";
   [self performSegueWithIdentifier:CMPlayVideoSegue sender:episode];
}
- (void)tappedPreviewEpisodeButton:(CMEpisode *)episode {
    EP_MODE = @"kEPPreview";
   [self performSegueWithIdentifier:CMPlayVideoSegue sender:episode];
}
- (IBAction)tabOnMoreInfoButton:(id)sender {
    [self performSegueWithIdentifier:CMMoreInfoSegue sender:self.cmMovie];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:CMPlayVideoSegue]) {
        CMVideoPlayerViewController *cmVideoPlayerViewController = segue.destinationViewController;
        if ([EP_MODE isEqualToString:@"kMoviePreview"]) {
            if ([sender isKindOfClass:[CMMovie class]])
            {
                cmVideoPlayerViewController.cmMovie = (CMMovie *)sender;
                cmVideoPlayerViewController.videomode = kMoviePreview;
            }
        }
        if ([EP_MODE isEqualToString:@"kEPPlay"]) {
            if ([sender isKindOfClass:[CMEpisode class]])
            {
                cmVideoPlayerViewController.cmEpisode = (CMEpisode *)sender;
                cmVideoPlayerViewController.videomode = kEPPlay;
            }
        }
        if ([EP_MODE isEqualToString:@"kEPPreview"]) {
            if ([sender isKindOfClass:[CMEpisode class]])
            {
                cmVideoPlayerViewController.cmEpisode = (CMEpisode *)sender;
                cmVideoPlayerViewController.videomode = kEPPreview;
            }
        }
        
    }
    if ([segue.identifier isEqualToString:CMMoreInfoSegue]) {
        CMMoreInfoViewController *cmMoreInfoSeque = segue.destinationViewController;
        cmMoreInfoSeque.cmMoive = (CMMovie *)sender;
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (IBAction)tabOnRentButton:(id)sender {
    if ([self.cmMovie.status isEqualToString:@"paid"]) {
        CMUser *cmUser = [CMUser sharedInstance];
        if (cmUser.isLogin) {
            UIAlertView* dialogRent = [[UIAlertView alloc] init];
            [dialogRent setDelegate:self];
            [dialogRent setTitle:[NSString stringWithFormat:@"Rent %@",self.cmMovie.thaiName]];
            [dialogRent setMessage:[NSString stringWithFormat:@"After you start the movie, you'll have %@ days to finish it.",self.cmMovie.period]];
            [dialogRent addButtonWithTitle:@"Cancel"];
            [dialogRent addButtonWithTitle:@"OK"];
            dialogRent.tag = 100;
            [dialogRent show];
            
        }else{
            UIAlertView* dialogSignin = [[UIAlertView alloc] init];
            [dialogSignin setDelegate:self];
            [dialogSignin setMessage:@"Please sign to Cloud Media."];
            [dialogSignin addButtonWithTitle:@"Cancel"];
            [dialogSignin addButtonWithTitle:@"OK"];
            dialogSignin.tag = 200;
            [dialogSignin show];
        }
    }
    
    
}

- (IBAction)tabOnWishlistButton:(id)sender {
    
    if (self.cmMovie.isWishList) {
//        [self removeFromWishList];
        [CMMovie removeFromWishlist:self.cmMovie.idMovie Block:^(BOOL isSuccess, NSString *message, NSError *error) {

            if (isSuccess) {
                self.cmMovie.wishlist = @"0";
                [self.wishlistButton setTitle:@"+ wishlist" forState:UIControlStateNormal];
            }else{
                UIAlertView* dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:self];
                [dialog setTitle:@"Alert"];
                [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
                [dialog addButtonWithTitle:@"Dismiss"];
                
                [dialog show];
            }

        }];
    }else{
        
        [CMMovie addToWishlist:self.cmMovie.idMovie Block:^(BOOL isSuccess, NSString *message, NSError *error) {
            if (isSuccess) {
                self.cmMovie.wishlist = @"1";
                [self.wishlistButton setTitle:@"- wishlist" forState:UIControlStateNormal];
            }else{
               UIAlertView* dialog = [[UIAlertView alloc] init];
               [dialog setDelegate:self];
               [dialog setTitle:@"Alert"];
               [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
               [dialog addButtonWithTitle:@"Dismiss"];
                
               [dialog show];
            }
        }];
        
    }
    
}



-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Tag == 100 is Rent Movie
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            //Cancel Rent
        }
        if (buttonIndex == 1){
            //OK Rent
            [CMMovie rentMovieWithID:self.cmMovie.idMovie Block:^(BOOL isSuccess, CMMovie *cmMovie, NSArray *cmEpisodes, NSString *message, NSError *error) {
                if (isSuccess){
                    _cmEpisode = cmEpisodes;
                    self.cmMovie = cmMovie;
                    [self setUpHeader];
                    [self reload];
                        UIAlertView* dialogAlertRentSuccess = [[UIAlertView alloc] init];
                        [dialogAlertRentSuccess setDelegate:self];
                        [dialogAlertRentSuccess setMessage:@"Rent Successfully"];
                        [dialogAlertRentSuccess addButtonWithTitle:@"Dismiss"];
                        dialogAlertRentSuccess.tag = 300;
                        [dialogAlertRentSuccess show];
                }else{
                        UIAlertView* dialogAlertRentProblem = [[UIAlertView alloc] init];
                        [dialogAlertRentProblem setDelegate:self];
                        [dialogAlertRentProblem setMessage:[NSString stringWithFormat:@"%@",message]];
                        [dialogAlertRentProblem addButtonWithTitle:@"Dismiss"];
                        dialogAlertRentProblem.tag = 400;
                        [dialogAlertRentProblem show];
                }
                
            }];
        }
  
    }
    
    //Tag == 200 is Login Dialog
    if (alertView.tag == 200) {
        if (buttonIndex == 0) {
            //Cancel Login
        }
        if (buttonIndex == 1) {
            //OK Go to Login Page
            [self performSegueWithIdentifier:CMMovieToAccountSegue sender:nil];
        }
    }
    
    //Tag == 300 is Result of rent success
    if (alertView.tag == 300) {
        if (buttonIndex == 0) {
            //RentSuccess dismiss
      
        }
    }
    
    //Tag == 400 is Result of rent fail
    if (alertView.tag == 400) {
        if (buttonIndex == 0) {
            //RentNOTSuccess dismiss
           
        }
    }

}


- (void)setUpHeader{
    if ([self.cmMovie.trailerLink isEqualToString:@""]) {
        self.previewMovieButton.hidden = YES;
    }
    
    if ([self.cmMovie.wishlist isEqualToString:@"1"]) {
        [self.wishlistButton setTitle:@"- wishlist" forState:UIControlStateNormal];
    }else{
        [self.wishlistButton setTitle:@"+ wishlist" forState:UIControlStateNormal];
    }
    
	self.navigationItem.title = self.cmMovie.thaiName;
    self.movieNameLabel.text = self.cmMovie.thaiName;
    self.movieDescriptionLabel.text = self.cmMovie.descriptionOfMovie;
    [self.movieThumbnailImageView setImageWithURL:[NSURL URLWithString:self.cmMovie.imageSmall]];
    
    
    if ([self.cmMovie.status isEqualToString:@"paid"]) {
        self.moviePriceLabel.text = [NSString stringWithFormat:@"%@P",self.cmMovie.price];
        self.rentButton.hidden = NO;
    }else if ([self.cmMovie.status isEqualToString:@"free"]) {
        self.rentButton.hidden = YES;
    }else if([self.cmMovie.status isEqualToString:@"available"]){
        self.rentButton.hidden = YES;
        self.moviePriceLabel.text = @"Available";
    }else if([self.cmMovie.status isEqualToString:@"expired"]){
        self.moviePriceLabel.text = [NSString stringWithFormat:@"Expired, Re-Rent %@P",self.cmMovie.price];
        self.rentButton.hidden = NO;
    }else{
        self.moviePriceLabel.text = [NSString stringWithFormat:@"%@P",self.cmMovie.price];
        self.rentButton.hidden = NO;
    }

}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self reload];
    [self setUpHeader];
}

@end
