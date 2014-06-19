//
//  Show.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Program;
@interface Show : NSObject

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *desc;
@property (nonatomic, readonly) NSString *thumbnailUrl;
@property (nonatomic, readonly) NSString *posterUrl;
@property (nonatomic, readonly) NSString *lastEp;
@property (nonatomic, readonly) NSString *detail;

@property (nonatomic, unsafe_unretained) BOOL isOTV;
@property (nonatomic, readonly) NSString *otvId;
@property (nonatomic, readonly) NSString *otvApiName;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithProgram:(Program *)program;
- (id)initWithRelateOTVShow:(NSDictionary *)dictionary;

+ (void)loadWhatsNewDataWithStart:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadCategoryDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadChannelDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadSearchDataWithKeyword:(NSString *)keyword Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadShowDataWithOtvId:(NSString *)Id Block:(void (^)(Show *show, NSError *error))block;
@end
