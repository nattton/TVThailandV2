//
//  OTVCategory.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVCategory.h"

#import "OTVApiClient.h"

@implementation OTVCategory {

}

- (NSString *)description {
    return [NSString stringWithFormat:@"idCate:%@, cateName:%@, title:%@, thumbnail:%@", self.IdCate, self.cateName, self.title, self.thumbnailUrl];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        _IdCate = [dictionary objectForKey:@"id"];
        _cateName = [dictionary objectForKey:@"api_name"];
        _title = [dictionary objectForKey:@"name_th"];
        _thumbnailUrl = [dictionary objectForKey:@"icon"];
    }
    return self;
}



+ (void)loadOTVCategory:(void (^)(NSArray *otvCategories, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [client GET:[NSString stringWithFormat:@"CategoryList/index/%@/%@/%@/",kOTV_APP_ID, kOTV_APP_VERSION, kOTV_API_VERSION ] parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jcategories = [responseObject valueForKeyPath:@"items"];
            NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jcategories count]];
            for (NSDictionary *dictCategory in jcategories){
                OTVCategory * category = [[OTVCategory alloc] initWithDictionary:dictCategory];
                [mutableCategories addObject:category];
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableCategories], nil);
            }
        
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block([NSArray array], error);
                
                NSLog(@"failure loadOTVCategory: %@", error);
//                NSLog(@"URL:%@",[NSString stringWithFormat:@"CategoryList/index/%@/%@/%@/",kOTV_APP_ID, kOTV_APP_VERSION, kOTV_API_VERSION ]);
            }
     
        }];
    
}


@end
