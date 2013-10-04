//
//  Show.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Show.h"
#import "ApiClient.h"
#import "Program.h"
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

- (NSString *)description {
    return [NSString stringWithFormat:@"Id: %@, Title: %@, Thumbnail: %@, Description: %@", _Id, _title, _thumbnailUrl, _desc];
}

#pragma mark - Load Data

+ (void)loadWhatsNewDataWithStart:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    [[ApiClient sharedInstance] getPath:[NSString stringWithFormat:@"api2/whatsnew/%d?device=ios&time%@", start, [df stringFromDate:[NSDate date]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *programs = [JSON valueForKeyPath:@"programs"];
        
        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programs count]];
        for (NSDictionary *dictShow in programs) {
            Show *show = [[Show alloc] initWithDictionary:dictShow];
            [mutablePrograms addObject:show];
        }
        
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
    
}

+ (void)loadCategoryDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    [[ApiClient sharedInstance] getPath:[NSString stringWithFormat:@"api2/category/%@/%d?device=ios&time=%@", Id, start, [df stringFromDate:[NSDate date]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *programs = [JSON valueForKeyPath:@"programs"];
        
        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programs count]];
        for (NSDictionary *dictShow in programs) {
            Show *show = [[Show alloc] initWithDictionary:dictShow];
            [mutablePrograms addObject:show];
        }
        
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
    
}

+ (void)loadChannelDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    [[ApiClient sharedInstance] getPath:[NSString stringWithFormat:@"api2/channel/%@/%d?device=ios&time=%@", Id, start, [df stringFromDate:[NSDate date]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *programs = [JSON valueForKeyPath:@"programs"];
        
        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programs count]];
        for (NSDictionary *dictShow in programs) {
            Show *show = [[Show alloc] initWithDictionary:dictShow];
            [mutablePrograms addObject:show];
        }
        
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
    
}

+ (void)loadSearchDataWithKeyword:(NSString *)keyword Block:(void (^)(NSArray *shows, NSError *error))block {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    [[ApiClient sharedInstance] getPath:[[NSString stringWithFormat:@"api2/search/0?keyword=%@&device=ios&time%@", keyword, [df stringFromDate:[NSDate date]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *programs = [JSON valueForKeyPath:@"programs"];
        
        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programs count]];
        for (NSDictionary *dictShow in programs) {
            Show *show = [[Show alloc] initWithDictionary:dictShow];
            [mutablePrograms addObject:show];
        }
        
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
    
}

@end
