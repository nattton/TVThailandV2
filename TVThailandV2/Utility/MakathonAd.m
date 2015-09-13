//
//  MakathonAd.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "MakathonAd.h"
#import "AFHTTPRequestOperationManager.h"

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

+ (void)retrieveData:(void (^)(NSArray *ads, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api2/advertise?device=ios&time%@", kAPI_URL_BASE, [df stringFromDate:[NSDate date]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *jAds = [responseObject valueForKeyPath:@"ads"];
        
        NSMutableArray *mutableAdss = [NSMutableArray arrayWithCapacity:[jAds count]];
        for (NSDictionary *dictAd in jAds) {
            MakathonAd * ad = [[MakathonAd alloc] initWithDictionary:dictAd];
            [mutableAdss addObject:ad];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableAdss], nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
