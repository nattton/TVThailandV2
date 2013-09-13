//
//  Show.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *desc;
@property (nonatomic, readonly) NSString *thumbnailUrl;
@property (nonatomic, readonly) NSString *posterUrl;
@property (nonatomic, readonly) NSString *lastEp;
@property (nonatomic, readonly) NSString *detail;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)loadWhatsNewDataWithStart:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadGenreDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;
+ (void)loadChannelDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block;

@end
