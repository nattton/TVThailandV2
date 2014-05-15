//
//  Radio.m
//  TVThailandV2
//
//  Created by April Smith on 5/15/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "Radio.h"
#import "ApiClient.h"

#import "NSString+Utils.h"


@implementation Radio

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"title"];
        _detail = [dictionary objectForKey:@"description"];
        _thumbnailUrl = [dictionary objectForKey:@"thumbnail"];
        _radioUrl = [dictionary objectForKey:@"url"];

    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, Title: %@,Description: %@, Thumbnail: %@, RadioURL: %@", _Id, _title, _detail, _thumbnailUrl, _radioUrl];
}

#pragma mark - Load Data

+ (void)loadData:(void (^)(NSArray *radios ,NSError *error))block {
    
    [[ApiClient sharedInstance]
     GET:[NSString stringWithFormat:@"api2/radio?device=ios&time=%@", [NSString getUnixTimeKey]]
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id JSON) {
         NSArray *jRadioes = [JSON valueForKeyPath:@"radios"];
         
         NSMutableArray *mutableRadioes = [NSMutableArray arrayWithCapacity:[jRadioes count]];
         for (NSDictionary *dictGenre in jRadioes) {
             Radio * radio = [[Radio alloc] initWithDictionary:dictGenre];
             [mutableRadioes addObject:radio];
         }
         
         if (block) {
             block([NSArray arrayWithArray:mutableRadioes], nil);
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
