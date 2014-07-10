//
//  OTVEpisode.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpisode.h"
#import "OTVApiClient.h"
#import "OTVShow.h"
#import "OTVPart.h"
#import "Show.h"

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

+ (void)loadOTVEpisodeAndPartWithCateName:(NSString *)cateName
                                   ShowID:(NSString *)showID
                                    start:(NSInteger)start
                                    Block:(void (^)(OTVShow *otvShow, NSArray *otvEpisodes, NSArray *ralateShows, NSError *error)) block
{
    
    OTVApiClient *client = [OTVApiClient sharedInstance];

    client.responseSerializer = [AFJSONResponseSerializer serializer];
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", nil];

    
    NSString *url = ([cateName isEqualToString:kOTV_CH7])
    ? [NSString stringWithFormat:@"Ch7/content/%@/%@", kOTV_APP_ID, showID]
    : [NSString stringWithFormat:@"Content/index/%@/%@/%@/%@/", kOTV_APP_ID, kAPP_VERSION, kOTV_API_VERSION, showID];
    
//    NSLog(@"URL===== http://api.otv.co.th/api/index.php/%@", url);
    
    [client GET:url
     parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
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
                        part.vastURL = ( dictPart[@"stream_url"] == nil || [dictPart[@"stream_url"] isEqualToString:@""] ) ? @"" : dictPart[@"stream_url"];
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
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block(nil, [NSArray array], [NSArray array], error);
                
                DLog(@"failure loadOTVEpisode: %@", error);
            }
            
        }];
    
}

+ (void)loadOTVEpisodeAndPart:(NSString *)cateName showID:(NSString *)showID start:(NSInteger)start Block:(void (^)(NSArray *otvEpisodes, NSError *error)) block{

    NSString *url = ([cateName isEqualToString:kOTV_CH7])
                    ? [NSString stringWithFormat:@"%@/content/%@/%@", kOTV_CH7, kOTV_APP_ID, showID]
                    : [NSString stringWithFormat:@"%@/detail/%@/%@/%@/%@/",cateName, kOTV_APP_ID, kAPP_VERSION, kOTV_API_VERSION, showID];
    
    OTVApiClient *client = [OTVApiClient sharedInstance];
    
    client.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [client GET:url
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
                
                if ([cateName isEqualToString:kOTV_CH7]) {
                    NSSortDescriptor *sortById = [NSSortDescriptor sortDescriptorWithKey:@"partId"
                                                                               ascending:YES];
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
            
            if (block) {
                block([NSArray arrayWithArray:mutableEpisodes], nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block([NSArray array], error);
                
                DLog(@"failure loadOTVEpisode: %@", error);
            }
        
    }];
    
}

@end
