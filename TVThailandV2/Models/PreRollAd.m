//
//  PreRollAd.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 1/16/2558 BE.
//  Copyright (c) 2558 luciferultram@gmail.com. All rights reserved.
//

#import "PreRollAd.h"
#import "AFMakathonClient.h"

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
    
    NSString *url = [NSString stringWithFormat:@"%@/api2/preroll_advertise?device=ios&time%@", kAPI_URL_BASE, [df stringFromDate:[NSDate date]]];
    [[AFMakathonClient sharedClient] GET:url parameters:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *jAds = [responseObject valueForKeyPath:@"ads"];
        
        NSMutableArray *mutableAdss = [NSMutableArray arrayWithCapacity:[jAds count]];
        for (NSDictionary *dictAd in jAds) {
            PreRollAd * ad = [[PreRollAd alloc] initWithDictionary:dictAd];
            [mutableAdss addObject:ad];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableAdss], nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], error);
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
