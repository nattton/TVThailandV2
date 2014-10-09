//
//  IMAAdPlaybackInfo.h
//  GoogleIMA3
//
//  Created by John Hicks on 3/19/13.
//

#import <Foundation/Foundation.h>

/// Groups various properties of the ad player.
@protocol IMAAdPlaybackInfo<NSObject>

/// The current media time of the ad, or 0 if no ad loaded.
@property(nonatomic, readonly) NSTimeInterval currentMediaTime;

/// The total media time of the ad, or 0 if no ad loaded.
@property(nonatomic, readonly) NSTimeInterval totalMediaTime;

/// The buffered media time of the ad, or 0 if no ad loaded.
@property(nonatomic, readonly) NSTimeInterval bufferedMediaTime;

/// YES if an ad is currently playing, NO otherwise.
@property(nonatomic, readonly, getter=isPlaying) BOOL playing;

@end
