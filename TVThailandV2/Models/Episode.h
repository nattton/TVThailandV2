//
//  Episode.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Show;
@interface Episode : NSObject

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSUInteger ep;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *videoEncrypt;
@property (nonatomic, readonly) NSString *srcType;
@property (nonatomic, readonly) NSString *updatedDate;
@property (nonatomic, readonly) NSString *viewCount;
@property (nonatomic, readonly) NSString *parts;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSArray *videos;
@property (nonatomic, readonly) NSString *titleDisplay;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)videoThumbnail:(NSUInteger)idx;
+ (void)loadEpisodeDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(Show *show, NSArray *episodes, NSError *error))block;


@end
