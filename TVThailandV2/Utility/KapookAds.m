//
//  KapookAds.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "KapookAds.h"
#import "AFHTTPRequestOperationManager.h"

@implementation KapookAds

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.url1x1 = [dict objectForKey:@"url_1x1"];
        self.urlShow = [dict objectForKey:@"url_show"];
    }
    return self;
}

+ (void)loadApi:(void (^)(KapookAds *kapook, NSError *error))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://kapi.kapook.com/partner/url"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             KapookAds *kapookAds = [[KapookAds alloc] initWithDictionary:responseObject];
             if (block) {
                 block(kapookAds, nil);
             }
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) {
                 block(nil, error);
             }
    }];
}

@end
