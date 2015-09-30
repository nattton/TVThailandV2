//
//  AFMakathonClient.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/30/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import "AFMakathonClient.h"

static NSString * const AFMakathonBaseURLString = @"http://tv.makathon.com";

@implementation AFMakathonClient

+ (instancetype)sharedClient {
    static AFMakathonClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFMakathonClient alloc] initWithBaseURL:[NSURL URLWithString:AFMakathonBaseURLString]];
    });
    
    return _sharedClient;
}

@end
