//
//  Show.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Show.h"
#import "Program.h"
#import "AFHTTPRequestOperationManager.h"

@implementation Show

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"title"];
        _thumbnailUrl = [dictionary objectForKey:@"thumbnail"];
        _desc = [dictionary objectForKey:@"description"];
        _lastEp = [dictionary objectForKey:@"last_epname"];
        _posterUrl = [dictionary objectForKey:@"poster"];
        _detail = [dictionary objectForKey:@"detail"];
        
        _isOTV = [[dictionary objectForKey:@"is_otv"] isEqualToString:@"1"];
        _otvId = [dictionary objectForKey:@"otv_id"];
        _otvApiName = [dictionary objectForKey:@"otv_api_name"];
        _otvLogo = [dictionary objectForKey:@"otv_logo"];
        
    }
    return self;
}


- (id)initWithProgram:(Program *)program {
    self = [super init];
    if (self) {
        _Id = program.program_id;
        _title = program.program_title;
        _thumbnailUrl = program.program_thumbnail;
        _desc = program.program_time;
    }
    return self;
}

- (id)initWithRelateOTVShow:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"name_th"];
        _thumbnailUrl = [dictionary objectForKey:@"thumbnail"];

        _isOTV = YES;
        _otvId = [dictionary objectForKey:@"content_season_id"];
        _otvApiName = @"";
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, OTV_Id: %@, isOTV: %@, Title: %@, Thumbnail: %@, Description: %@", _Id, _otvId, _isOTV?@"YES":@"NO" ,_title, _thumbnailUrl, _desc];
}

#pragma mark - Load Data

+ (void)loadShowDataWithURL:(NSString *)URLString Block:(void (^)(NSArray *shows, NSError *error))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *programs = [responseObject valueForKeyPath:@"programs"];
        
        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programs count]];
        for (NSDictionary *dictShow in programs) {
            Show *show = [[Show alloc] initWithDictionary:dictShow];
            [mutablePrograms addObject:show];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+ (void)loadWhatsNewDataWithStart:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    NSString *url = [NSString stringWithFormat:@"%@/api2/whatsnew/%@?device=ios&time%@",
                                       kAPI_URL_BASE,
                                       [[NSNumber numberWithInteger:start] stringValue],
                                       [df stringFromDate:[NSDate date]]];
    
    [Show loadShowDataWithURL:url Block:block];
}

+ (void)loadCategoryDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    NSString *url = [NSString stringWithFormat:@"%@/api2/category/%@/%@?device=ios&app_version=%@&build=%@&time=%@", kAPI_URL_BASE,
                                       Id,
                                       [[NSNumber numberWithInteger:start] stringValue],
                                       kAPP_VERSION,
                                       kAPP_BUILD,
                                       [df stringFromDate:[NSDate date]]];
    
    [Show loadShowDataWithURL:url Block:block];
}

+ (void)loadChannelDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api2/channel/%@/%@?device=ios&app_version=%@&build=%@&time=%@", kAPI_URL_BASE,
                                        Id,
                                        [[NSNumber numberWithInteger:start] stringValue],
                                        kAPP_VERSION,
                                        kAPP_BUILD,
                                        [df stringFromDate:[NSDate date]]];
    
    [Show loadShowDataWithURL:url Block:block];
}

+ (void)loadSearchDataWithKeyword:(NSString *)keyword Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    NSString *url = [[NSString stringWithFormat:@"%@/api2/search/0?keyword=%@&device=ios&time%@", kAPI_URL_BASE, keyword, [df stringFromDate:[NSDate date]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [Show loadShowDataWithURL:url Block:block];
}

+ (void)loadShowDataWithOtvId:(NSString *)Id Block:(void (^)(Show *show, NSError *error))block {
    if (!Id) return;
    
    NSString *url = [NSString stringWithFormat:@"%@/api2/program_info_otv/%@?device=ios", kAPI_URL_BASE, Id];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        Show *show;
        NSDictionary *dictShow = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
        if (dictShow) {
            show = [[Show alloc] initWithDictionary:dictShow];
            show.isOTV = YES;
        }
        
        if (block) {
            block(show, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

@end
