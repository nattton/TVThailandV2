//
//  AdsClient.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 4/3/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "CMVideoAds.h"
#import "DDXML.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+Utils.h"
#import "DVVideoAdServingTemplate.h"
#import "DVVideoAdServingTemplate+Parsing.h"
#import "DVWrapperVideoAd.h"

@interface CMVideoAds () <NSXMLParserDelegate>


@end

NSString * const kTrackingEventTypeArray[] = {
    @"complete",
    @"start",
    @"midpoint",
    @"firstQuartile",
    @"thirdQuartile",
    @"pause",
    @"replay",
    @"fullscreen",
    @"stop",
    @"resume",
    @"mute",
    @"unmute"
};

@implementation CMVideoAds {
    NSString *currentTag;
    NSString *currentEvent;
    NSString *currentMediaFileType;
    
    NSMutableDictionary *tempTrackingEvents;
}

static NSString *kVast = @"VAST";
static NSString *kVASTAdTagURI = @"VASTAdTagURI";
static NSString *kAdTitle = @"AdTitle";
static NSString *kImpression = @"Impression";
static NSString *kClickThrough = @"ClickThrough";
static NSString *kTrackingEvents = @"TrackingEvents";
static NSString *kTracking = @"Tracking";
static NSString *kEvent = @"event";
static NSString *kMediaFile = @"MediaFile";
static NSString *kType = @"type";
static NSString *kMediaTypeMP4 = @"mp4";
static NSString *kMediaFileMP4 = @"video/mp4";
static NSString *kMediaFileXMP4 = @"video/x-mp4";

-(NSString *) trackingTypeEnumToString:(kTrackingEventType)eventType
{
    return kTrackingEventTypeArray[eventType];
}

-(kTrackingEventType) trackingEventTypeStringToEnum:(NSString*)string
{
    int retVal = 0;
    for(int i=0; i < sizeof(kTrackingEventTypeArray)-1; i++)
    {
        if([(NSString*)kTrackingEventTypeArray[i] isEqual:string])
        {
            retVal = i;
            break;
        }
    }
    return (kTrackingEventType)retVal;
}

- (id)initWithVastTagURL:(NSString *)url {
    self = [super init];
    if (self) {
        self.URL = url;
        [self loadWithVastTagURL:url];
    }
    return self;
}

- (void)loadWithVastTagURL:(NSString *)url {
    NSString *vastURL = [url stringByReplacingOccurrencesOfString:@"[timestamp]"
                                                       withString:[NSString getUnixTime]];
    
    tempTrackingEvents = [[NSMutableDictionary alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:vastURL]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSError *error = nil;
         
         DVVideoAdServingTemplate *adTemplate = [[DVVideoAdServingTemplate alloc] initWithData:data error:&error];
         NSArray *ads = adTemplate.ads;
         for (id ad in ads)
         {
             DLog(@"%@", NSStringFromClass([ad class]));
             if ([@"DVInlineVideoAd" isEqualToString:NSStringFromClass([ad class])])
             {
                 self.ad = (DVInlineVideoAd *)ad;
             }
             else if ([@"DVWrapperVideoAd" isEqualToString:NSStringFromClass([ad class])])
             {
                 DVWrapperVideoAd *wrapperAd = (DVWrapperVideoAd *)ad;
                 
                 [self loadWithVastTagURL:[wrapperAd.URL absoluteString]];
                 
                 return;
             }
             
             if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestVideoAds:success:)]) {
                 
                 if (self.ad)
                 {
                     [self.delegate didRequestVideoAds:self success:YES];
                 }
                 else
                 {
                     [self.delegate didRequestVideoAds:self success:NO];
                 }
                 
                 return;
             }
         }
     }];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"Title : %@\nImpresion : %@\nClickThrough : %@\nMediaFile : %@",
            self.ad.title, [self.ad.impressionURL absoluteString] , [self.ad.clickThroughURL absoluteString], [self.ad.mediaFileURL absoluteString]];
}

#pragma mark - Hit Request

- (void) hitTrackingEvent:(kTrackingEventType)eventType {
    if (eventType == START) {
        [self.ad trackImpressions];
    }
    
    NSString * eventString = [self trackingTypeEnumToString:eventType];
    [self.ad trackEvent:eventString];
}

@end
