//
//  RadioPlayerViewController.m
//  TVThailandV2
//
//  Created by April Smith on 5/16/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Radio.h"

@interface RadioPlayerViewController () {
        CGRect _frame;
}

@property (strong, nonatomic) MPMoviePlayerController *movieController;


-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers:(MPMoviePlayerController *)player;
-(void)removeMovieNotificationHandlers:(MPMoviePlayerController *)player;
-(void)deletePlayerAndNotificationObservers:(MPMoviePlayerController *)player;
- (void) movieDurationAvailableDidChange:(NSNotification*)notification;


@end

@implementation RadioPlayerViewController

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
    
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:_radio.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"]];

    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _frame = CGRectMake(0, 0, 598 , 40);

    }
    else
    {
        _frame = CGRectMake(0, 0, 320 , 40);

    }
    
    [self playRadioStream:[NSURL URLWithString: _radio.radioUrl ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


- (void)playRadioStream:(NSURL *)radioFileURL
{
    
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    
    if ([[radioFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:radioFileURL];
    [self installMovieNotificationObservers:self.movieController];
    
    self.movieController.allowsAirPlay = YES;
    self.movieController.movieSourceType = movieSourceType;
    [self.movieController prepareToPlay];
    [self.movieController play];
    
    self.movieController.controlStyle = MPMovieControlStyleNone;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        self.movieController.controlStyle = MPMovieControlStyleFullscreen;
    });
    
    
    
    
    self.movieController.controlStyle = MPMovieControlStyleEmbedded;
//    MPMovieControlStyleNone,       // No controls
//    MPMovieControlStyleEmbedded,   // Controls for an embedded view
//    MPMovieControlStyleFullscreen, // Controls for fullscreen playback
//    MPMovieControlStyleDefault = MPMovieControlStyleEmbedded
    
    
    
    
    self.movieController.view.frame = _frame;
    [self.radioView addSubview:self.movieController.view];
    
//    [self.view addSubview:self.movieController.view];
    [self.movieController setFullscreen:YES animated:NO];
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
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
    
    
}




@end
