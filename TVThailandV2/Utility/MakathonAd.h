//
//  MakathonAd.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MakathonAd : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *type;

+ (void)loadAds:(void (^)(NSArray *shows, NSError *error))block;

@end
