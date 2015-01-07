//
//  OTVCategory.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVCategory : NSObject

@property (nonatomic, readonly) NSString *IdCate;
@property (nonatomic, readonly) NSString *cateName;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *thumbnailUrl;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)retrieveData:(void (^)(NSArray *otvCategories, NSError *error)) block;

- (id)initWithId:(NSString *)IdCate CateName:(NSString *)cateName Title:(NSString *)title ThumbnailURL:(NSString *)thubmnailURL;
+ (OTVCategory *)initWithCH7;

@end
