//
//  OTVApiClient.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVApiClient.h"

@implementation OTVApiClient

+ (id) sharedInstance {
    static OTVApiClient *__sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[OTVApiClient alloc] initWithBaseURL:[NSURL URLWithString:kOTV_URL_BASE]];
    });
    
    return __sharedInstance;
}

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
//        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    
    return self;
}

@end
