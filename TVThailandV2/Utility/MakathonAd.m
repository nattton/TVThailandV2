//
//  MakathonAd.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "MakathonAd.h"
#import "IAHTTPCommunication.h"

@implementation MakathonAd

- (id)initWithDictionary:(NSDictionary *)ad {
    self = [super init];
    if (self) {
        self.name = [ad objectForKey:@"name"];
        self.url = [ad objectForKey:@"url"];
        self.time = [ad objectForKey:@"time"];
        self.type = @"url";
    }
    return self;
}
#pragma mark - Load Data

+ (void)loadAds:(void (^)(NSArray *ads, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api2/advertise?device=ios&time%@", kAPI_URL_BASE, [df stringFromDate:[NSDate date]]]];
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
                MakathonAd * ad = [[MakathonAd alloc] initWithDictionary:dictAd];
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

@end
