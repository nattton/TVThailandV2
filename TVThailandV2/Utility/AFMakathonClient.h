//
//  AFMakathonClient.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/30/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface AFMakathonClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
