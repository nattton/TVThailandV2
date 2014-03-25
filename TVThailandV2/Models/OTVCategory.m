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
        _IdCate = ([dictionary objectForKey:@"id"]?[dictionary objectForKey:@"id"]:[NSString string]);
        _cateName = ([dictionary objectForKey:@"api_name"]?[dictionary objectForKey:@"api_name"]:[NSString string]);
        _title = ([dictionary objectForKey:@"name_th"]?[dictionary objectForKey:@"name_th"]:[NSString string]);
        _thumbnailUrl = ([dictionary objectForKey:@"icon"]?[dictionary objectForKey:@"icon"]:[NSString string]);
        if ([_thumbnailUrl isKindOfClass:[NSNull class]]) {
            _thumbnailUrl = [NSString string];
        }
    }
    return self;
}

- (id)initWithId:(NSString *)IdCate CateName:(NSString *)cateName Title:(NSString *)title ThumbnailURL:(NSString *)thubmnailURL {
    self = [super init];
    if (self) {
        _IdCate = IdCate;
        _cateName = cateName;
        _title = title;
        _thumbnailUrl = thubmnailURL;
    }
    return self;
}
+ (OTVCategory *)initWithCH7{
    return [[OTVCategory alloc]initWithId:kOTV_CH7 CateName:kOTV_CH7 Title:@"ช่อง 7" ThumbnailURL:@""];
}

+ (void)loadOTVCategory:(void (^)(NSArray *otvCategories, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [client GET:[NSString stringWithFormat:@"CategoryList/index/%@/%@/%@/",kOTV_APP_ID, kOTV_APP_VERSION, kOTV_API_VERSION ] parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jcategories = [responseObject valueForKeyPath:@"items"];
            
            // Capacity + (1)Ch7
            NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jcategories count] + 1];
            OTVCategory * category = [OTVCategory initWithCH7];
            
            [mutableCategories addObject:category];
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
