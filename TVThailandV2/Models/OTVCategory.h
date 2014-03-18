//
//  OTVCategory.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVCategory : NSObject

@property (strong, nonatomic) NSString *IdCate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *thumbnailUrl;


- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id) initWithIdOfOTV:(NSString *)newID
                 title:(NSString *)newTitle
             thumbnail:(NSString *)newThumbnail;

+ (OTVCategory *)categoryWithIdOfOTV:(NSString *)newID
                               title:(NSString *)newTitle
                           thumbnail:(NSString *)newThumbnail;


+ (void)loadOTVCategory:(void (^)(NSArray *otvCategories, NSError *error)) block;

@end
