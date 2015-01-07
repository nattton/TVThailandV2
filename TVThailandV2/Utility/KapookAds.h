//
//  KapookAds.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KapookAds : NSObject

@property (nonatomic, strong) NSString *url1x1;
@property (nonatomic, strong) NSString *urlShow;

+ (void)retrieveData:(void (^)(KapookAds *kapook, NSError *error))block;

@end
