//
//  Channel.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Channel.h"
#import "ApiClient.h"

#import "NSString+Utils.h"

@implementation Channel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"title"];
        _thumbnailUrl = [dictionary objectForKey:@"thumbnail"];
        _videoUrl = [dictionary objectForKey:@"url"];
        _isHasEp = [dictionary objectForKey:@"has_show"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, Title: %@, Thumbnail: %@, URL: %@, isHasEp: %@", _Id, _title, _thumbnailUrl, _videoUrl, _isHasEp];
}

#pragma mark - Load Data

+ (void)loadData:(void (^)(NSArray *channels ,NSError *error))block {
     
    [[ApiClient sharedInstance]
         GET:[NSString stringWithFormat:@"api2/channel?device=ios&app_version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]]
         parameters:nil
         success:^(AFHTTPRequestOperation *operation, id JSON) {
             NSArray *jCategories = [JSON valueForKeyPath:@"channels"];
             
             NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
             for (NSDictionary *dictGenre in jCategories) {
                 Channel * channel = [[Channel alloc] initWithDictionary:dictGenre];
                 [mutableCategories addObject:channel];
             }
             
             if (block) {
                 block([NSArray arrayWithArray:mutableCategories], nil);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) {
                 block([NSArray array], error);
             }
         }
     ];
}

@end
