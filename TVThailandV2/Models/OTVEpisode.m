//
//  OTVEpisode.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpisode.h"
#import "OTVApiClient.h"
#import "OTVPart.h"

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

+ (void)loadOTVEpisodeAndPart:(NSString *)cateName showID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block{
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [client GET:[NSString stringWithFormat:@"%@/detail/%@/%@/%@/%@/",cateName, kOTV_APP_ID, kOTV_APP_VERSION, kOTV_API_VERSION, showID]
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            NSArray *jEpisodes = [responseObject valueForKey:@"contentList"];
            NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[jEpisodes count]];
            
            for (NSDictionary *dictEp in jEpisodes){
                

                OTVEpisode *episode = [[OTVEpisode alloc]initWithDictionary:dictEp];
                
//                NSLog(@"EP:%@, Part_count: %d", episode.date , [episode.parts count]);
                
                NSInteger count = 0;
                NSString *vast_url_temp = @"";
                NSMutableArray *mutableParts = [NSMutableArray arrayWithCapacity:[episode.parts count]];
                for (NSDictionary *dictPart in [episode parts]) {
                    OTVPart *part = [[OTVPart alloc]initWithDictionary:dictPart];
                    
                    if ((count+1)%2 == 0) {
                        part.vastURL = vast_url_temp;
                        [mutableParts addObject:part ];
//                        NSLog(@"Part: %@",[part description]);
                    } else {
                        vast_url_temp = part.streamURL;
                    }
                    count++;
                }

                episode.parts = [NSArray arrayWithArray:mutableParts];
                
                [mutableEpisodes addObject:episode];
                
                
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableEpisodes], nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block([NSArray array], error);
                
                NSLog(@"failure loadOTVEpisode: %@", error);
            }
        
    }];
    
}

+ (void)loadOTVEpisodeAndPartOfCH7:(NSString *)cateName showID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block {
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [client GET:[NSString stringWithFormat:@"%@/content/2/%@",kOTV_CH7,showID]
     parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *jEpisodes = [responseObject valueForKey:@"contentList"];
            NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[jEpisodes count]];
            
            for (NSDictionary *dictEp in jEpisodes){
                
                
                OTVEpisode *episode = [[OTVEpisode alloc]initWithDictionary:dictEp];
                
                NSInteger count = 0;

                NSString *vast_url_temp = @"";
                NSMutableArray *mutableParts = [NSMutableArray arrayWithCapacity:[episode.parts count]/2];
                
                for (NSDictionary *dictPart in [episode parts]) {
                    
                    OTVPart *part = [[OTVPart alloc]initWithDictionary:dictPart];
                    
                    if ((count+1)%2 == 0) {
                        part.vastURL = vast_url_temp;
                        
                        [mutableParts addObject:part ];

                    } else {
                        vast_url_temp = part.streamURL;
                    }
                    count++;

                    
                }
                
                NSSortDescriptor *sortById = [NSSortDescriptor sortDescriptorWithKey:@"partId"
                                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortById];
                NSArray *sortedArray = [mutableParts sortedArrayUsingDescriptors:sortDescriptors];
                
                
                episode.parts = [NSArray arrayWithArray:sortedArray];
                
                [mutableEpisodes addObject:episode];
                
                
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableEpisodes], nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block([NSArray array], error);
                
                NSLog(@"failure loadOTVEpisodeOfCH7: %@", error);
            }
            
        }];
    
}

@end
