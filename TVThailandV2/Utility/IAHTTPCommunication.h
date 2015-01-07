//
//  IAHTTPCommunication.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 1/7/2558 BE.
//  Copyright (c) 2558 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAHTTPCommunication : NSObject <NSURLSessionDownloadDelegate>

@property (nonatomic, copy) void (^successBlock) (NSData *response);

- (void)retrieveURL:(NSURL *)url
       successBlock:(void (^)(NSData *))successBlock;
- (void)retrieveURL:(NSURL *)url
          userAgent:(NSString *)userAgent
       successBlock:(void (^)(NSData *response))successBlock;
- (void)postURL:(NSURL *)url params:(NSDictionary *)params
   successBlock:(void (^)(NSData *))successBlock;
- (void)postURL:(NSURL *)url userAgent:(NSString *)userAgent params:(NSDictionary *)params
   successBlock:(void (^)(NSData *))successBlock;
@end
