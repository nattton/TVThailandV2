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
    return [NSString stringWithFormat:@"idCate:%@, title:%@, thumbnail:%@", self.IdCate, self.title, self.thumbnailUrl];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        _IdCate = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"name_th"];
        _thumbnailUrl = [dictionary objectForKey:@"icon"];
    }
    return self;
}

- (id) initWithIdOfOTV:(NSString *)newID
                 title:(NSString *)newTitle
             thumbnail:(NSString *)newThumbnail {
    self = [super init];
    if (self) {
        self.IdCate = newID;
        self.title = newTitle;
        self.thumbnailUrl = newThumbnail;
    }
    
    return self;
}

+ (OTVCategory *)categoryWithIdOfOTV:(NSString *)newID
                               title:(NSString *)newTitle
                           thumbnail:(NSString *)newThumbnail {
    
    return [[OTVCategory alloc] initWithIdOfOTV:newID title:newTitle thumbnail:newThumbnail];
}

+ (void)loadOTVCategory:(void (^)(NSArray *otvCategories, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
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
