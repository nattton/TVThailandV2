//
//  CMPlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 4/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "CMPlayerViewController.h"

CGFloat kMovieViewOffsetX = 0.0;
CGFloat kMovieViewOffsetY = 0.0;


@interface CMPlayerViewController()
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType;
-(void)applyUserSettingsToMoviePlayer;
-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers;
-(void)removeMovieNotificationHandlers;
-(void)deletePlayerAndNotificationObservers;

@end

@implementation CMPlayerViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Movie Player Controller Methods
#pragma mark -

#pragma mark Create and Play Movie URL

/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and
 controls to the existing view hierarchy.
 */


- (void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player)
    {
        /* Save the movie object */
        [self setMoviePlayerController:player];
        
        /* Register the current object as an observer for the movie notifications. */
        [self installMovieNotificationObservers];
        
        /* Specify the URL that points to the movie file. */
        [player setContentURL:movieURL];
        
        /* If you specify the movie type before playing the movie it can result in faster loasd times. */
        [player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
        [self applyUserSettingsToMoviePlayer];
        
        /* Add a background view as a subview to hide our other view controls underneath during movie playback. */
        [player.view addSubview:self.backgroundView];
//        [self.view addSubview:self.backgroundView];
        
        
        CGRect viewInsetRect = CGRectInset ([self.view bounds], kMovieViewOffsetX, kMovieViewOffsetY);
        [[player view] setFrame:viewInsetRect];

        /* Inset the movie frame in the parent view frame. */
//        [[player view] setFrame:self.view.frame];
        player.view.translatesAutoresizingMaskIntoConstraints = NO;
        
//        [player view].backgroundColor = [UIColor lightGrayColor];
        
        /* To present a movie in your application, incorporate the view contained in a movie player's view property into application's view hierarchy. Be sure to size the frame correctly. */
        [self.view addSubview: [player view]];
        
//        [player.view addSubview:self.backgroundView];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    MPMoviePlayerController *player = [self moviePlayerController];
    CGRect viewInsetRect = CGRectInset ([self.view bounds], kMovieViewOffsetX, kMovieViewOffsetY);
    [[player view] setFrame:viewInsetRect];
}

- (void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
    [self.moviePlayerController play];
}

- (void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    
    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    
    [self createAndPlayMovieForURL:movieFileURL sourceType:movieSourceType];
}

#pragma mark Movie Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            [self performSelectorOnMainThread:@selector(displayError:) withObject:[notification userInfo][@"error"]
                                waitUntilDone:NO];
//            [self removeMovieViewFromViewHierarchy];
//            [self removeOverlayView];
            self.backgroundView.hidden = YES;
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
//            [self removeMovieViewFromViewHierarchy];
//            [self removeOverlayView];
            [self.backgroundView removeFromSuperview];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
			break;
            
		default:
			break;
	}
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
        self.backgroundView.hidden = YES;
        
        // Add an overlay view on top of the movie view
//        [self addOverlayView];
//        
//        [overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
//
//	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
        self.backgroundView.hidden = NO;
//        [overlayController setLoadStateDisplayString:@"stalled"];
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
	MPMoviePlayerController *player = notification.object;
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
//        [overlayController setPlaybackStateDisplayString:@"stopped"];
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
//        [overlayController setPlaybackStateDisplayString:@"playing"];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
//        [overlayController setPlaybackStateDisplayString:@"paused"];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
//        [overlayController setPlaybackStateDisplayString:@"interrupted"];
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

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
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

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];
}



-(void)applyUserSettingsToMoviePlayer
{
    MPMoviePlayerController *player = [self moviePlayerController];
    if (player)
    {
//        player.scalingMode = [MoviePlayerUserPrefs scalingModeUserSetting];
        [player setFullscreen:YES animated:YES];
        player.controlStyle = MPMovieControlStyleFullscreen;
//        player.backgroundView.backgroundColor = [MoviePlayerUserPrefs backgroundColorUserSetting];
//        player.repeatMode = [MoviePlayerUserPrefs repeatModeUserSetting];
//        if ([MoviePlayerUserPrefs backgroundImageUserSetting] == YES)
//        {
//            [self.movieBackgroundImageView setFrame:[self.view bounds]];
//            [player.backgroundView addSubview:self.movieBackgroundImageView];
//        }
//        else
//        {
//            [self.movieBackgroundImageView removeFromSuperview];
//        }
        
        /* Indicate the movie player allows AirPlay movie playback. */
        player.allowsAirPlay = YES;
    }
}

#pragma mark Error Reporting

-(void)displayError:(NSError *)theError
{
	if (theError)
	{
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [theError localizedDescription]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
		[alert show];
	}
}

@end
