//
//  CategoryList.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Genre;
@interface GenreList : NSObject
@property (nonatomic, readonly) NSUInteger count;

- (id)initWithSamples;
- (void)loadData:(void (^)(NSError *error))block;
- (Genre *)genreAtIndex:(NSUInteger)idx;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
