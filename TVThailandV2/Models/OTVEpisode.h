//
//  OTVEpisode.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVEpisode : NSObject

@property (nonatomic, readonly) NSString *contentId;
@property (nonatomic, readonly) NSString *nameTh;
@property (nonatomic, readonly) NSString *nameEn;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *thumbnail;
@property (nonatomic, readonly) NSString *cover;
@property (nonatomic, readonly) NSString *ratingStatus;
@property (nonatomic, readonly) NSString *ratingPoint;
@property (nonatomic, readonly) NSString *date;
@property (nonatomic, strong) NSArray *parts;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)loadOTVEpisodeAndPartWithShowID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block;

//+ (void)loadOTVEpisodeAndPart:(NSString *)cateName showID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block;
//
//+ (void)loadOTVEpisodeAndPartOfCH7:(NSString *)cateName showID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block;

@end
