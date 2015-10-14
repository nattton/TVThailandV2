//
//  Channel.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Channel.h"
#import "AFMakathonClient.h"
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

+ (void)retrieveData:(void (^)(NSArray *channels ,NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"api2/channel?device=ios&version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]];
    [[AFMakathonClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSArray *jCategories = [responseObject valueForKeyPath:@"channels"];
        NSMutableArray *mutableCategories = [NSMutableArray arrayWithCapacity:[jCategories count]];
        for (NSDictionary *dictGenre in jCategories) {
            Channel * channel = [[Channel alloc] initWithDictionary:dictGenre];
            [mutableCategories addObject:channel];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableCategories], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
