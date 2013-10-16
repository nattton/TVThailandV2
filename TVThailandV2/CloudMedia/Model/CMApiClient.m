//
//  CMApiClient.m
//  CloudMedia
//
//  Created by April Smith on 10/3/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAPIBaseURLString = @"http://www.cloudmediathai.com/tv/";


@implementation CMApiClient



+ (id) sharedInstance {
    static CMApiClient *__sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CMApiClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return __sharedInstance;
}

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        // custom setting
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        //        [self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    }
    
    return self;
}



@end
