//
//  CMApiClient.h
//  CloudMedia
//
//  Created by April Smith on 10/3/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "AFHTTPClient.h"

@interface CMApiClient : AFHTTPClient

+ (id) sharedInstance;

@end
