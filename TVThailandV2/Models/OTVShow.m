//
//  OTVShow.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShow.h"
#import "OTVApiClient.h"

@implementation OTVShow

- (NSString *)description {
    return [NSString stringWithFormat:@"idShow:%@, title:%@, detail:%@, thumbnail%@", self.idShow, self.title, self.detail, self.thumbnail];
//    return [NSString stringWithFormat:@"idShow:%@, title:%@, detail:%@", self.idShow, self.title, self.detail];
}

- (id) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        _idShow = ([dictionary objectForKey:@"id"]?[dictionary objectForKey:@"id"]:[NSString string]);
        _title = ([dictionary objectForKey:@"name_th"]?[dictionary objectForKey:@"name_th"]:[NSString string]);
        _detail = ([dictionary objectForKey:@"detail"]?[dictionary objectForKey:@"detail"]:[NSString string]);
        _thumbnail = ([dictionary objectForKey:@"thumbnail"]?[dictionary objectForKey:@"thumbnail"]:[NSString string]);
        if ([_thumbnail isKindOfClass:[NSNull class]]) {
            _thumbnail = [NSString string];
        }
    }
    return self;
}

+ (void)loadOTVShow:(NSString *)cate_name Start:(NSInteger)start Block:(void (^)(NSArray *otvShows, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [client GET:[NSString stringWithFormat:@"%@/index/%@/%@/%@/%d/50/", cate_name, kOTV_APP_ID, kOTV_APP_VERSION, kOTV_API_VERSION, start]
     parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *jShows = [responseObject valueForKeyPath:@"items"];
            NSMutableArray *mutableShows = [NSMutableArray arrayWithCapacity:[jShows count]];
            
            for (NSDictionary *dictShow in jShows) {
                OTVShow * show = [[OTVShow alloc] initWithDictionary:dictShow];
                [mutableShows addObject:show];
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableShows], nil);
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block([NSArray array], error);
                
                DLog(@"failure loadOTVShow: %@", error);
            }
        }];
}

+ (void)loadOTVShowWithCH7:(NSString *)cate_name Start:(NSInteger)start Block:(void (^)(NSArray *otvShows, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [client GET:[NSString stringWithFormat:@"%@/drama", cate_name]
     parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *jShows = [responseObject valueForKeyPath:@"items"];
            NSMutableArray *mutableShows = [NSMutableArray arrayWithCapacity:[jShows count]];
            
            for (NSDictionary *dictShow in jShows) {
                OTVShow * show = [[OTVShow alloc] initWithDictionary:dictShow];
                [mutableShows addObject:show];
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableShows], nil);
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block([NSArray array], error);
                
                DLog(@"failure loadOTVShowWithCH7: %@", error);
            }
        }];
}

@end
