//
//  Radio.h
//  TVThailandV2
//
//  Created by April Smith on 5/15/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Radio : NSObject

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *thumbnailUrl;
@property (nonatomic, readonly) NSString *radioUrl;
@property (nonatomic, readonly) NSString *category;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)retrieveData:(void (^)(NSArray *radioCategories, NSArray *radios ,NSError *error))block;

@end
