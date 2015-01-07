//
//  IAHTTPCommunication.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 1/7/2558 BE.
//  Copyright (c) 2558 luciferultram@gmail.com. All rights reserved.
//

#import "IAHTTPCommunication.h"

@implementation IAHTTPCommunication

- (void)retrieveURL:(NSURL *)url
       successBlock:(void (^)(NSData *response))successBlock {
    [self retrieveURL:url userAgent:nil successBlock:successBlock];
}

- (void)retrieveURL:(NSURL *)url
          userAgent:(NSString *)userAgent
       successBlock:(void (^)(NSData *response))successBlock {
    self.successBlock = successBlock;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if (userAgent) {
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

- (void)postURL:(NSURL *)url params:(NSDictionary *)params
   successBlock:(void (^)(NSData *))successBlock {
    [self postURL:url userAgent:nil params:params successBlock:successBlock];
}

- (void)postURL:(NSURL *)url userAgent:(NSString *)userAgent params:(NSDictionary *)params
   successBlock:(void (^)(NSData *))successBlock {
    self.successBlock = successBlock;
    
    NSMutableArray *parameterArray = [NSMutableArray arrayWithCapacity:[params count]];
    for (NSString *key in params) {
        [parameterArray addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    
    NSString *postBodyString = [parameterArray componentsJoinedByString:@"&"];
    NSData *postBodyData = [NSData dataWithBytes:[postBodyString UTF8String] length:[postBodyString length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
   if (userAgent) {
       [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
   }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postBodyData];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.successBlock(data);
    });
}

@end
