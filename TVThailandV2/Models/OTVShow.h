//
//  OTVShow.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVShow : NSObject

@property (strong, nonatomic) NSString *idShow;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *thumbnail;


- (id) initWithDictionary:(NSDictionary *) dictionary;
+ (void)loadOTVShow:(NSString *)cate_name Start:(NSInteger)start Block:(void (^)(NSArray *otvShows, NSError *error)) block;


@end
