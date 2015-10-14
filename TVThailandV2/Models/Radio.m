//
//  Radio.m
//  TVThailandV2
//
//  Created by April Smith on 5/15/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "Radio.h"
#import "AFMakathonClient.h"
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
        _category = [dictionary objectForKey:@"category"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, Title: %@,Description: %@, Thumbnail: %@, RadioURL: %@, Category: %@", _Id, _title, _detail, _thumbnailUrl, _radioUrl, _category];
}

#pragma mark - Load Data

+ (void)retrieveData:(void (^)(NSArray *radioCategories, NSArray *radios, NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"api2/radio?device=ios&version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]];
    [[AFMakathonClient sharedClient] GET:url parameters:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *jRadioes = [responseObject valueForKeyPath:@"radios"];
        NSSet *categorySet = [NSSet setWithArray:[jRadioes valueForKeyPath:@"category"]];
        NSArray *radioCategories = [[categorySet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSMutableArray *mutableRadios = [NSMutableArray arrayWithCapacity:[radioCategories count]];
        
        for (NSString *category in radioCategories) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.category contains[c] %@", category];
            NSArray *filterRadios = [jRadioes filteredArrayUsingPredicate:predicate];
            
            NSMutableArray *mutableRadioSet = [NSMutableArray arrayWithCapacity:[filterRadios count]];
            for (NSDictionary *jRadio in filterRadios) {
                Radio * radio = [[Radio alloc] initWithDictionary:jRadio];
                [mutableRadioSet addObject:radio];
            }
            [mutableRadios addObject:mutableRadioSet];
        }
        
        if (block) {
            block(radioCategories, [NSArray arrayWithArray:mutableRadios], nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], [NSArray array], error);
        }
    }];
}

@end
