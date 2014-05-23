//
//  RadioListViewController.m
//  TVThailandV2
//
//  Created by April Smith on 5/23/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioListViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "Radio.h"
#import "RadioTableViewCell.h"

#import "SVProgressHUD.h"

@interface RadioListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableOfRadio;
@property (weak, nonatomic) IBOutlet UIView *radioPlayerView;

@property (strong, nonatomic) MPMoviePlayerController *radioController;

-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers:(MPMoviePlayerController *)player;
-(void)removeMovieNotificationHandlers:(MPMoviePlayerController *)player;
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player;
- (void) movieDurationAvailableDidChange:(NSNotification*)notification;

@end

@implementation RadioListViewController {
    NSArray *_radioes;
    Radio *radioSelected;
    CGRect _frame;
    UIAlertView *alert;
}


//** cell Identifier **//
static NSString *radioCellIdentifier = @"radioCellIdentifier";

//** sending segue **//
static NSString *showRadioPlayerSegue = @"showRadioPlayerSegue";


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
    
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [Radio loadData:^(NSArray *radios, NSError *error) {
        [SVProgressHUD dismiss];
        _radioes = radios;
        [self.tableOfRadio reloadData];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //Watch on demand program
    }

}


- (void)playRadioStream:(NSURL *)radioStreamURL {
    
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    
    if ([[radioStreamURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    self.radioController = [[MPMoviePlayerController alloc] initWithContentURL:radioStreamURL];
    [self installMovieNotificationObservers:self.radioController];
    
    self.radioController.allowsAirPlay = YES;
    self.radioController.movieSourceType = movieSourceType;
    [self.radioController prepareToPlay];
    [self.radioController play];
    
    self.radioController.controlStyle = MPMovieControlStyleNone;
    
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        //code to be executed on the main queue after delay
//        self.radioController.controlStyle = MPMovieControlStyleFullscreen;
//    });
    
    
    
    
    self.radioController.controlStyle = MPMovieControlStyleEmbedded;
    //    MPMovieControlStyleNone,       // No controls
    //    MPMovieControlStyleEmbedded,   // Controls for an embedded view
    //    MPMovieControlStyleFullscreen, // Controls for fullscreen playback
    //    MPMovieControlStyleDefault = MPMovieControlStyleEmbedded
    
    
    
    
    self.radioController.view.frame = _frame;
    [self.radioPlayerView addSubview:self.radioController.view];
    
    //    [self.view addSubview:self.movieController.view];
//    [self.radioController setFullscreen:NO animated:NO];
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers:(MPMoviePlayerController *)player
{
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieDurationAvailableDidChange:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:player];
    
}


/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
    //	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
        //        [self.overlayController setLoadStateDisplayString:@"n/a"];
        //
        //        [overlayController setLoadStateDisplayString:@"unknown"];
	}
    //
    //	/* The buffer has enough data that playback can begin, but it
    //	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
        //        [overlayController setLoadStateDisplayString:@"playable"];
	}
    //
    //	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        //        self.backgroundView.hidden = YES;
        
        // Add an overlay view on top of the movie view
        //        [self addOverlayView];
        //
        //        [overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
    //
    //	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
        //        self.backgroundView.hidden = NO;
        //        [overlayController setLoadStateDisplayString:@"stalled"];
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        DLog(@"%@", @"stopped");
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        DLog(@"%@", @"playing");
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        DLog(@"%@", @"paused");
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        DLog(@"%@", @"interrupted");
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    //    [self addOverlayView];
}

- (void) movieDurationAvailableDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    DLog(@"%f", player.currentPlaybackTime);
}


#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers:(MPMoviePlayerController *)player
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player
{
    [self removeMovieNotificationHandlers:player];
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    
    
    MPMoviePlayerController *player = [notification object];
    
    [self removeMovieNotificationHandlers:player];
    [self.radioController.view removeFromSuperview];
    self.radioController = nil;
    
    
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _radioes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    RadioTableViewCell *cellOfRadio = [tableView dequeueReusableCellWithIdentifier:radioCellIdentifier];
    cellOfRadio.selectedBackgroundView = selectedBackgroundViewForCell;
    
    if ( _radioes && [_radioes count] > 0) {
        [cellOfRadio configureWithRadio:_radioes[indexPath.row]];
    }
    
    return  cellOfRadio;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    radioSelected = _radioes[indexPath.row];
    
    if (radioSelected.radioUrl == nil || [radioSelected.radioUrl length] == 0 )  {
        [alert show];
    } else {
        [self playRadioStream:[NSURL URLWithString:radioSelected.radioUrl]];
    }
    
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    

}


@end
