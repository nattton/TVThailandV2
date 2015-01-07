//
//  Radio.m
//  TVThailandV2
//
//  Created by April Smith on 5/15/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "Radio.h"
#import "IAHTTPCommunication.h"
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
    IAHTTPCommunication *http = [[IAHTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/api2/radio?device=ios&app_version=%@&build=%@&time=%@",kAPI_URL_BASE, kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]]];
    [http retrieveURL:url successBlock:^(NSData *response) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                             options:0
                                                               error:&error];
        if (!error) {
            NSArray *jRadioes = [data valueForKeyPath:@"radios"];
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
        } else {
            if (block) {
                 block([NSArray array], [NSArray array], error);
            }
        }
    }];
}


//+ (void)loadData:(void (^)(NSArray *radioCategories, NSArray *radios ,NSError *error))block {
//    
//    [[ApiClient sharedInstance]
//     GET:[NSString stringWithFormat:@"api2/radio?device=ios&app_version=%@&build=%@&time=%@", kAPP_VERSION, kAPP_BUILD, [NSString getUnixTimeKey]]
//     parameters:nil
//     success:^(AFHTTPRequestOperation *operation, id JSON) {
//         NSArray *jRadioes = [JSON valueForKeyPath:@"radios"];
//         NSSet *categorySet = [NSSet setWithArray:[jRadioes valueForKeyPath:@"category"]];
//         NSArray *radioCategories = [[categorySet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//         NSMutableArray *mutableRadios = [NSMutableArray arrayWithCapacity:[radioCategories count]];
//         
//         for (NSString *category in radioCategories) {
//             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.category contains[c] %@", category];
//             NSArray *filterRadios = [jRadioes filteredArrayUsingPredicate:predicate];
//             
//             NSMutableArray *mutableRadioSet = [NSMutableArray arrayWithCapacity:[filterRadios count]];
//             for (NSDictionary *jRadio in filterRadios) {
//                 Radio * radio = [[Radio alloc] initWithDictionary:jRadio];
//                 [mutableRadioSet addObject:radio];
//             }
//             [mutableRadios addObject:mutableRadioSet];
//         }
//         
//         if (block) {
//             block(radioCategories, [NSArray arrayWithArray:mutableRadios], nil);
//         }
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         if (block) {
//             block([NSArray array], [NSArray array], error);
//         }
//     }
//     ];
//}

@end
