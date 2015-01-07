//
//  CategoryList.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowCategoryList.h"
#import "ShowCategory.h"
#import "IAHTTPCommunication.h"

#import "NSString+Utils.h"

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
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/api2/category?device=ios&app_version=%@&build=%@&time=%@", kAPI_URL_BASE, kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]]];
    [http retrieveURL:url successBlock:^(NSData *response) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                             options:0
                                                               error:&error];
        if (!error) {
            NSArray *jCategories = [data valueForKeyPath:@"categories"];
            
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
            
        } else {
            if (block) {
                block(error);
            }
        }
    }];
}

//- (void)loadData:(void (^)(NSError *error))block {
//    NSString *url = [NSString stringWithFormat:@"api2/category?device=ios&app_version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]];
//    [[ApiClient sharedInstance]
//            GET:url
//     parameters:nil
//        success:^(AFHTTPRequestOperation *operation, id JSON) {
//             NSArray *jCategories = [JSON valueForKeyPath:@"categories"];
//             
//             NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
//             for (NSDictionary *dictCategory in jCategories) {
//                 ShowCategory * category = [[ShowCategory alloc] initWithDictionary:dictCategory];
//                 [mutableCategories addObject:category];
//             }
//             
//             if ([mutableCategories count] == 0) {
//                 [mutableCategories addObject:[[ShowCategory alloc] initWithDictionary:[self whatsNewData]]];
//             }
//             
//             categories = [NSArray arrayWithArray:mutableCategories];
//             
//             
//             if (block) {
//                 block(nil);
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             if (block) {
//                 block(error);
//             }
//         }
//     ];
//}

@end
