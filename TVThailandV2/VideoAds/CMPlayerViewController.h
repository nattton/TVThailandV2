//
//  CMPlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 4/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CMPlayerViewController : UIViewController
{
@private
    MPMoviePlayerController *moviePlayerController;
    IBOutlet UIView *backgroundView;
}


@property (strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;

- (void)playMovieStream:(NSURL *)movieFileURL;

@end
