//
//  OTVEpisode.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpisode.h"
#import "OTVShow.h"
#import "OTVPart.h"
#import "Show.h"
#import "AFHTTPSessionManager.h"

@implementation OTVEpisode

- (NSString *)description {
    return [NSString stringWithFormat:@"contentId:%@, nameTh:%@, detail:%@, thumbnail:%@,  date:%@", _contentId, _nameTh, _detail, _thumbnail, _date];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        _contentId = ([dictionary objectForKey:@"content_id"]?[dictionary objectForKey:@"content_id"]:[NSString string]);
        _nameTh = ([dictionary objectForKey:@"name_th"]?[dictionary objectForKey:@"name_th"]:[NSString string]);
        _detail = ([dictionary objectForKey:@"detail"]?[dictionary objectForKey:@"detail"]:[NSString string]);
        _thumbnail = ([dictionary objectForKey:@"thumbnail"]?[dictionary objectForKey:@"thumbnail"]:[NSString string]);
        if ([_thumbnail isKindOfClass:[NSNull class]]) {
            _thumbnail = [NSString string];
        }
        _date = ([dictionary objectForKey:@"date"]?[dictionary objectForKey:@"date"]:[NSString string]);

        _parts = ([dictionary objectForKey:@"item"]?[dictionary objectForKey:@"item"]:[NSString string]);
        
        NSDateFormatter *_df = [[NSDateFormatter alloc] init];
        NSDateFormatter *_thaiFormat = [[NSDateFormatter alloc] init];
        
        [_df setDateFormat:@"yyyy-MM-dd"];
        [_thaiFormat setDateFormat:@"dd MMMM yyyy"];
        [_thaiFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th"]];
        
        _date = [_date isEqualToString:@""] ? _date : [NSString stringWithFormat:@"ออกอากาศ %@",
                                                       [_thaiFormat stringFromDate:[_df dateFromString: _date]]];

        
    }
    
    return  self;
}

// v202
+ (void)retrieveDataWithCateName:(NSString *)cateName
                          ShowID:(NSString *)showID
                           start:(NSInteger)start
                           Block:(void (^)(OTVShow *otvShow, NSArray *otvEpisodes, NSArray *ralateShows, NSError *error)) block {
    NSString *url = [NSString stringWithFormat:@"%@/Content/index/%@/%@/%@/%@/0/50/0", kOTV_URL_BASE,kOTV_APP_ID, kAPP_VERSION, kOTV_API_VERSION, showID];
    NSString  *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:currentDeviceId forHTTPHeaderField:@"X-Device-ID"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        OTVShow *otvShow = [[OTVShow alloc] initWithDictionary:responseObject];
        
        /** OTV Episode content **/
        NSArray *jEpisodes = [responseObject valueForKey:@"contentList"];
        NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[jEpisodes count]];
        
        for (NSDictionary *dictEp in jEpisodes){
            
            
            OTVEpisode *episode = [[OTVEpisode alloc]initWithDictionary:dictEp];
            
            NSMutableArray *mutableParts = [NSMutableArray arrayWithCapacity:[episode.parts count]];
            OTVPart *part;
            for (NSDictionary *dictPart in [episode parts]) {
                
                if (!part) {
                    part = [[OTVPart alloc]init];
                }
                
                NSString *mediaCode = dictPart[@"media_code"] != nil ? dictPart[@"media_code"] : @"";
                
                if ([@"1001"  isEqual: mediaCode]) {
                    part.vastURL = ( dictPart[@"stream_url"] != nil) ? dictPart[@"stream_url"]: @"";
                    part.vastType = (dictPart[@"vast_type"] != nil) ? dictPart[@"vast_type"]: @"";
                } else if ([@"1000"  isEqual: mediaCode] || [@"1002"  isEqual: mediaCode]) {
                    
                    [part setPartContent:dictPart];
                    [mutableParts addObject:part ];
                    part = nil;
                }
            }
            
            if ([cateName isEqualToString:kOTV_CH7]) {
                NSSortDescriptor *sortById = [NSSortDescriptor sortDescriptorWithKey:@"partId" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortById];
                NSArray *sortedArray = [mutableParts sortedArrayUsingDescriptors:sortDescriptors];
                
                episode.parts = [NSArray arrayWithArray:sortedArray];
            }
            else
            {
                episode.parts = [NSArray arrayWithArray:mutableParts];
            }
            
            [mutableEpisodes addObject:episode];
            
            
        }
        
        /** OTV Show relate content **/
        NSArray *jRelateShows = [responseObject valueForKey:@"relate_content"];
        NSMutableArray *mutableRelateShows = [NSMutableArray arrayWithCapacity:[jRelateShows count]];
        
        for (NSDictionary *dictShow in jRelateShows){
            Show *relateShow = [[Show alloc] initWithRelateOTVShow:dictShow];
            [mutableRelateShows addObject:relateShow];
        }
        
        if (block) {
            block(otvShow, [NSArray arrayWithArray:mutableEpisodes], [NSArray arrayWithArray:mutableRelateShows], nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block(nil, [NSArray array], [NSArray array], error);
            
            DLog(@"failure loadOTVEpisode: %@", error.localizedDescription);
        }
    }];
    
}

//+ (void)retrieveDataWithCateName:(NSString *)cateName
//                          ShowID:(NSString *)showID
//                           start:(NSInteger)start
//                           Block:(void (^)(OTVShow *otvShow, NSArray *otvEpisodes, NSArray *ralateShows, NSError *error)) block {
//    
//    NSString *url = [NSString stringWithFormat:@"%@/Episodelist/index/%@/%@/%@/%@/%@/%d/%d", kOtvDomain, kOtvDevCode, kOtvSecretKey, kOtvAppID, kOtvAppVersion, showID, 0, 50];
//    
////    NSString *url = [NSString stringWithFormat:@"%@/Content/index/%@/%@/%@/%@/0/50/0", kOTV_URL_BASE,kOTV_APP_ID, kAPP_VERSION, kOTV_API_VERSION, showID];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
//        OTVShow *otvShow = [[OTVShow alloc] initWithDictionary:responseObject];
//        
//        /** OTV Episode content **/
//        NSArray *jEpisodes = [responseObject valueForKey:@"contentList"];
//        NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[jEpisodes count]];
//        
//        for (NSDictionary *dictEp in jEpisodes){
//            
//            
//            OTVEpisode *episode = [[OTVEpisode alloc]initWithDictionary:dictEp];
//            
//            NSMutableArray *mutableParts = [NSMutableArray arrayWithCapacity:[episode.parts count]];
//            OTVPart *part;
//            for (NSDictionary *dictPart in [episode parts]) {
//                
//                if (!part) {
//                    part = [[OTVPart alloc]init];
//                }
//                
//                NSString *mediaCode = dictPart[@"media_code"] != nil ? dictPart[@"media_code"] : @"";
//                
//                if ([@"1001"  isEqual: mediaCode]) {
//                    part.vastURL = ( dictPart[@"stream_url"] != nil) ? dictPart[@"stream_url"]: @"";
//                    part.vastType = (dictPart[@"vast_type"] != nil) ? dictPart[@"vast_type"]: @"";
//                } else if ([@"1000"  isEqual: mediaCode] || [@"1002"  isEqual: mediaCode]) {
//                    
//                    [part setPartContent:dictPart];
//                    [mutableParts addObject:part ];
//                    part = nil;
//                }
//            }
//            
//            if ([cateName isEqualToString:kOTV_CH7]) {
//                NSSortDescriptor *sortById = [NSSortDescriptor sortDescriptorWithKey:@"partId" ascending:YES];
//                NSArray *sortDescriptors = [NSArray arrayWithObject:sortById];
//                NSArray *sortedArray = [mutableParts sortedArrayUsingDescriptors:sortDescriptors];
//                
//                episode.parts = [NSArray arrayWithArray:sortedArray];
//            }
//            else
//            {
//                episode.parts = [NSArray arrayWithArray:mutableParts];
//            }
//            
//            [mutableEpisodes addObject:episode];
//            
//            
//        }
//        
//        /** OTV Show relate content **/
//        NSArray *jRelateShows = [responseObject valueForKey:@"relate_content"];
//        NSMutableArray *mutableRelateShows = [NSMutableArray arrayWithCapacity:[jRelateShows count]];
//        
//        for (NSDictionary *dictShow in jRelateShows){
//            Show *relateShow = [[Show alloc] initWithRelateOTVShow:dictShow];
//            [mutableRelateShows addObject:relateShow];
//        }
//        
//        if (block) {
//            block(otvShow, [NSArray arrayWithArray:mutableEpisodes], [NSArray arrayWithArray:mutableRelateShows], nil);
//        }
//    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
//        if (block) {
//            block(nil, [NSArray array], [NSArray array], error);
//            
//            DLog(@"failure loadOTVEpisode: %@", error.localizedDescription);
//        }
//    }];
//    
//}

@end
