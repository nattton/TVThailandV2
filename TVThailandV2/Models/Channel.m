//
//  Channel.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Channel.h"
#import "ApiClient.h"

@implementation Channel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"title"];
        _thumbnailUrl = [dictionary objectForKey:@"thumbnail"];
        _videoUrl = [dictionary objectForKey:@"url"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, Title: %@, Thumbnail: %@, URL: %@", _Id, _title, _thumbnailUrl, _videoUrl];
}

#pragma mark - Load Data

+ (void)loadData:(void (^)(NSArray *channels ,NSError *error))block {
    [[ApiClient sharedInstance]
         GET:@"api2/channel?device=ios"
         parameters:nil
         success:^(NSURLSessionDataTask *task, id JSON) {
             NSArray *jCategories = [JSON valueForKeyPath:@"categories"];
             
             NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
             for (NSDictionary *dictGenre in jCategories) {
                 Channel * channel = [[Channel alloc] initWithDictionary:dictGenre];
                 [mutableCategories addObject:channel];
             }
             
             if (block) {
                 block([NSArray arrayWithArray:mutableCategories], nil);
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             if (block) {
                 block([NSArray array], error);
             }
         }
     ];
}

@end
