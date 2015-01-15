//
//  PreRollAd.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 1/16/2558 BE.
//  Copyright (c) 2558 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreRollAd : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *skipTime;

+ (void)retrieveData:(void (^)(NSArray *ads, NSError *error))block;
+ (PreRollAd *)selectedAd:(NSArray *)ads;

@end
