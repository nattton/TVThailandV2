//
//  MakathonAd.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "MakathonAd.h"
#import "ApiClient.h"

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
    
    [[ApiClient sharedInstance]
     GET:[NSString stringWithFormat:@"api2/advertise?device=ios&time%@", [df stringFromDate:[NSDate date]]] parameters:nil
     success:^(AFHTTPRequestOperation *operation, id JSON) {
         NSArray *jAds = [JSON valueForKeyPath:@"ads"];
         
         NSMutableArray *mutableAdss = [NSMutableArray arrayWithCapacity:[jAds count]];
         for (NSDictionary *dictAd in jAds) {
             MakathonAd * ad = [[MakathonAd alloc] initWithDictionary:dictAd];
             [mutableAdss addObject:ad];
//             DLog(@"ad name : %@, url : %@", ad.name, ad.url);
         }
         
         if (block) {
             block([NSArray arrayWithArray:mutableAdss], nil);
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (block) {
             block([NSArray array], error);
         }
     }
 ];
}

@end
