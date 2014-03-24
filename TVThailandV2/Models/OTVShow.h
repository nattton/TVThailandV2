//
//  OTVShow.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVShow : NSObject

@property (nonatomic, readonly) NSString *idShow;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *thumbnail;


- (id) initWithDictionary:(NSDictionary *) dictionary;
+ (void)loadOTVShow:(NSString *)cate_name Start:(NSInteger)start Block:(void (^)(NSArray *otvShows, NSError *error)) block;


@end
