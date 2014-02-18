//
//  CategoryList.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowCategoryList.h"
#import "ShowCategory.h"
#import "ApiClient.h"

@implementation ShowCategoryList {
    NSArray *categories;
}

- (NSUInteger)count {
    return categories.count;
}

- (id)initWithSamples {
    self = [super init];
    if (self) {
        categories = @[
  [[ShowCategory alloc] initWithDictionary:@{@"id":@"1",@"title":@"\u0e25\u0e30\u0e04\u0e23\u0e44\u0e17\u0e22",@"description":@"\u0e25\u0e30\u0e04\u0e23\u0e44\u0e17\u0e22",@"thumbnail":@"http://thumbnail.instardara.com/category/01_cate_thaimovie.png"}],
  
  [[ShowCategory alloc] initWithDictionary:@{@"id":@"2",@"title":@"\u0e0b\u0e34\u0e17\u0e04\u0e2d\u0e21",@"description":@"",@"thumbnail":@"http://thumbnail.instardara.com/category/02_cate_sitcom.png"}],
  [[ShowCategory alloc] initWithDictionary:@{@"id":@"3",@"title":@"\u0e27\u0e32\u0e44\u0e23\u0e15\u0e35\u0e49 / \u0e40\u0e01\u0e21\u0e2a\u0e4c\u0e42\u0e0a\u0e27\u0e4c",@"description":@"",@"thumbnail":@"http://thumbnail.instardara.com/category/03_cate_gameshow.png"}],
  [[ShowCategory alloc] initWithDictionary:@{@"id":@"13",@"title":@"Music",@"description":@"Music Video",@"thumbnail":@"http://thumbnail.instardara.com/category/05_cate_music.png"}],
  [[ShowCategory alloc] initWithDictionary:@{@"id":@"5",@"title":@"\u0e02\u0e48\u0e32\u0e27",@"description":@"",@"thumbnail":@"http://thumbnail.instardara.com/category/04_cate_news.png"}]
  ];
                   
    }
    return self;
}

- (ShowCategory *)genreAtIndex:(NSUInteger)idx {
    return categories[idx];
}
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return categories[idx];
}

#pragma mark - Load Data

- (void)loadData:(void (^)(NSError *error))block {
    [[ApiClient sharedInstance]
        GET:@"api2/category?device=ios"
        parameters:nil
         success:^(AFHTTPRequestOperation *operation, id JSON) {
             NSArray *jCategories = [JSON valueForKeyPath:@"categories"];
             
             NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
             for (NSDictionary *dictCategory in jCategories) {
                 ShowCategory * category = [[ShowCategory alloc] initWithDictionary:dictCategory];
                 [mutableCategories addObject:category];
             }
             
             categories = [NSArray arrayWithArray:mutableCategories];
             
             if (block) {
                 block(nil);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) {
                 block(error);
             }
         }
     ];
}

@end
