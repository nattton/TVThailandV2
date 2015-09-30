//
//  CategoryList.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowCategoryList.h"
#import "ShowCategory.h"

#import "NSString+Utils.h"
#import "AFMakathonClient.h"

@implementation ShowCategoryList {
    NSArray *categories;
}

- (NSUInteger)count {
    return categories.count;
}

- (id)initWithWhatsNew {
    self = [super init];
    if (self) {
        categories = @[[[ShowCategory alloc] initWithDictionary:[self whatsNewData]]];
                   
    }
    return self;
}

- (NSDictionary *)whatsNewData {
    return @{@"id":@"recents",
             @"title":@"รายการล่าสุด",
             @"thumbnail":@""
             };
}

- (ShowCategory *)genreAtIndex:(NSUInteger)idx {
    return categories[idx];
}
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return categories[idx];
}

#pragma mark - Load Data

- (void)retrieveData:(void (^)(NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"api2/category?device=ios&app_version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]];
    [[AFMakathonClient sharedClient] GET:url parameters:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *jCategories = [responseObject valueForKeyPath:@"categories"];
        NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
        for (NSDictionary *dictCategory in jCategories) {
            ShowCategory * category = [[ShowCategory alloc] initWithDictionary:dictCategory];
            [mutableCategories addObject:category];
        }
        
        if ([mutableCategories count] == 0) {
            [mutableCategories addObject:[[ShowCategory alloc] initWithDictionary:[self whatsNewData]]];
        }
        
        categories = [NSArray arrayWithArray:mutableCategories];
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

@end
