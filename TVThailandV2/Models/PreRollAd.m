//
//  PreRollAd.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 1/16/2558 BE.
//  Copyright (c) 2558 luciferultram@gmail.com. All rights reserved.
//

#import "PreRollAd.h"
#import "IAHTTPCommunication.h"

@implementation PreRollAd

- (id)initWithDictionary:(NSDictionary *)ad {
    self = [super init];
    if (self) {
        self.name = [ad objectForKey:@"name"];
        self.url = [ad objectForKey:@"url"];
        self.skipTime = [ad objectForKey:@"skip_time"];
    }
    return self;
}
#pragma mark - Load Data

+ (void)retrieveData:(void (^)(NSArray *ads, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api2/preroll_advertise?device=ios&time%@", kAPI_URL_BASE, [df stringFromDate:[NSDate date]]]];
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    [http retrieveURL:url successBlock:^(NSData *response) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                             options:0
                                                               error:&error];
        if (!error) {
            NSArray *jAds = [data valueForKeyPath:@"ads"];
            
            NSMutableArray *mutableAdss = [NSMutableArray arrayWithCapacity:[jAds count]];
            for (NSDictionary *dictAd in jAds) {
                PreRollAd * ad = [[PreRollAd alloc] initWithDictionary:dictAd];
                [mutableAdss addObject:ad];
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableAdss], nil);
            }
        } else {
            if (block) {
                block([NSArray array], error);
            }
        }
    }];
}

+ (PreRollAd *)selectedAd:(NSArray *)ads {
    if ([ads count] > 0) {
        int x = arc4random() % [ads count];
        PreRollAd *ad = [ads objectAtIndex:x];
        return ad;
        
    }
    return nil;
}

@end
