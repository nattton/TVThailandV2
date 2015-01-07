//
//  CategoryList.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShowCategory;
@interface ShowCategoryList : NSObject
@property (nonatomic, readonly) NSUInteger count;

- (id)initWithWhatsNew;
- (void)retriveData:(void (^)(NSError *error))block;
- (ShowCategory *)genreAtIndex:(NSUInteger)idx;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
