//
//  KapookAds.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "KapookAds.h"
#import "IAHTTPCommunication.h"

@implementation KapookAds

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.url1x1 = [dict objectForKey:@"url_1x1"];
        self.urlShow = [dict objectForKey:@"url_show"];
    }
    return self;
}

+ (void)retrieveData:(void (^)(KapookAds *kapook, NSError *error))block {
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://kapi.kapook.com/partner/url"];
    [http retrieveURL:url successBlock:^(NSData *response) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                            options:0
                                                              error:&error];
        if (!error) {
            KapookAds *kapookAds = [[KapookAds alloc] initWithDictionary:data];
            if (block) {
                block(kapookAds, nil);
            }
        } else {
            if (block) {
                block(nil, error);
            }
        }
    }];
}

@end
