//
//  AdsClient.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 4/3/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    COMPLETE,
    START,
    MIDPOINT,
    FIRST_QUARTILE,
    THIRD_QUARTILE,
    PAUSE,
    REPLAY,
    FULLSCREEN,
    STOP,
    RESUME,
    MUTE,
    UNMUTE
} kTrackingEventType;


@class DVInlineVideoAd;
@protocol CMVideoAdsDelegate;

@interface CMVideoAds : NSObject

@property (nonatomic, weak) id <CMVideoAdsDelegate> delegate;

@property (strong, nonatomic) DVInlineVideoAd *ad;

//@property (nonatomic, strong) NSString *vastURL;
//
//@property (nonatomic, strong) NSString *adTitle;
//@property (nonatomic, strong) NSString *impression;
//@property (nonatomic, strong) NSString *vastAdTagURI;
//@property (nonatomic, strong) NSString *clickThrough;
//@property (nonatomic, strong) NSString *mediaFile;
//@property (nonatomic, strong) NSDictionary *trackingEvents;


- (id)initWithVastTagURL:(NSString *)url;
- (NSString *) trackingTypeEnumToString:(kTrackingEventType)eventType;
- (kTrackingEventType) trackingEventTypeStringToEnum:(NSString *)string;

- (void) hitTrackingEvent:(kTrackingEventType)eventType;

@end

@protocol CMVideoAdsDelegate <NSObject>

- (void)didRequestVideoAds:(CMVideoAds *)videoAds success:(BOOL)success;
- (void)didRequestVideoAds:(CMVideoAds *)videoAds error:(NSError *)error;


@end