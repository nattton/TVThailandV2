//
//  ApiClient.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ApiClient.h"

@implementation ApiClient

+ (id) sharedInstance {
    static ApiClient *__sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[ApiClient alloc] initWithBaseURL:[NSURL URLWithString:kAPI_URL_BASE]];
    });
    
    return __sharedInstance;
}

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        
    }
    
    return self;
}

@end
