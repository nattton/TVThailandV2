//
//  Episode.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Episode.h"
#import "ApiClient.h"
#import "Show.h"

#import "Base64.h"

@implementation Episode {
    NSString *_titleDisplay;
    NSArray *_videos;
    
    NSDateFormatter *_df;
    NSDateFormatter *_thaiFormat;
    NSNumberFormatter *_numberFormatter;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _ep = [[dictionary objectForKey:@"ep"] intValue];
        _title = [dictionary objectForKey:@"title"];
        _videoEncrypt = [dictionary objectForKey:@"video_encrypt"];
        _srcType = [dictionary objectForKey:@"src_type"];
//        _date = [dictionary objectForKey:@"date"];
        _viewCount = [dictionary objectForKey:@"view_count"];
        _parts = [dictionary objectForKey:@"parts"];
        _password = [dictionary objectForKey:@"pwd"];
        
        
        _df = [[NSDateFormatter alloc] init];
        _thaiFormat = [[NSDateFormatter alloc] init];
        _numberFormatter = [[NSNumberFormatter alloc] init];
        
        [_df setDateFormat:@"yyyy-MM-dd"];
        [_thaiFormat setDateFormat:@"dd MMMM yyyy"];
        [_thaiFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th"]];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        _date = [NSString stringWithFormat:@"ออกอากาศ %@",
                 [_thaiFormat stringFromDate:[_df dateFromString: [dictionary objectForKey:@"date"]]]];
        _viewCount = [NSString stringWithFormat:@"%@ views",
                      [_numberFormatter stringFromNumber:[NSNumber numberWithInt:[[dictionary objectForKey:@"count"] intValue]]]];
        
    }
    return self;
}

+ (void)loadEpisodeDataWithId:(NSString *)Id Start:(NSUInteger)start Block:(void (^)(Show *show, NSArray *episodes, NSError *error))block {
    
    if (!Id) return;
    
    [[ApiClient sharedInstance] getPath:[NSString stringWithFormat:@"api2/episode/%@/%d?device=ios", Id, start] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        Show *show;
        NSDictionary *dictShow = [JSON valueForKey:@"info"];
        if (dictShow) {
            show = [[Show alloc] initWithDictionary:dictShow];
        }
        
        NSArray *episodes = [JSON valueForKeyPath:@"episodes"];
        NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[episodes count]];
        for (NSDictionary *dict in episodes) {
            Episode *episode = [[Episode alloc] initWithDictionary:dict];
            [mutableEpisodes addObject:episode];
        }
        
        
        if (block) {
            block(show, [NSArray arrayWithArray:mutableEpisodes], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, [NSArray array], error);
        }
    }];
    
}

-(NSString *)titleDisplay {
    if (_titleDisplay == nil) {
        NSMutableString *display = [NSMutableString string];
        if (_ep > 20000000) {
            if ([_title isEqualToString:@""]) {
                [display appendString:_date];
            } else {
                [display appendString:_title];
            }
        } else {
            [display appendFormat:@"ตอนที่ %d", _ep];
            if (![_title isEqualToString:@""]) {
                [display appendFormat:@" - %@", _title];
            }
        }
        _titleDisplay = [NSString stringWithString:display];
    }
    return _titleDisplay;
}

- (NSString *)videoDecrypt {
    NSString *videoStr = [[[[[[[[[[[[[[[[[[[[[[_videoEncrypt
                                 stringByReplacingOccurrencesOfString:@"-" withString:@"+"]
                                stringByReplacingOccurrencesOfString:@"/" withString:@"/"]
                               stringByReplacingOccurrencesOfString:@"," withString:@"="]
                              stringByReplacingOccurrencesOfString:@"!" withString:@"a"]
                             stringByReplacingOccurrencesOfString:@"@" withString:@"b"]
                            stringByReplacingOccurrencesOfString:@"#" withString:@"c"]
                           stringByReplacingOccurrencesOfString:@"$" withString:@"d"]
                          stringByReplacingOccurrencesOfString:@"%" withString:@"e"]
                         stringByReplacingOccurrencesOfString:@"^" withString:@"f"]
                        stringByReplacingOccurrencesOfString:@"&" withString:@"g"]
                       stringByReplacingOccurrencesOfString:@"*" withString:@"h"]
                      stringByReplacingOccurrencesOfString:@"(" withString:@"i"]
                    stringByReplacingOccurrencesOfString:@")" withString:@"j"]
                   stringByReplacingOccurrencesOfString:@"{" withString:@"k"]
                  stringByReplacingOccurrencesOfString:@"}" withString:@"l"]
                 stringByReplacingOccurrencesOfString:@"[" withString:@"m"]
                stringByReplacingOccurrencesOfString:@"]" withString:@"n"]
               stringByReplacingOccurrencesOfString:@":" withString:@"o"]
              stringByReplacingOccurrencesOfString:@";" withString:@"p"]
             stringByReplacingOccurrencesOfString:@"<" withString:@"q"]
            stringByReplacingOccurrencesOfString:@">" withString:@"r"]
           stringByReplacingOccurrencesOfString:@"?" withString:@"s"];
    [Base64 initialize];
    NSData *data = [Base64 decode:videoStr];
    videoStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return videoStr;
}

- (NSArray *)videos {
    if(!_videos){
        _videos = [[self videoDecrypt] componentsSeparatedByString:@","];
    }
    return _videos;
}

- (NSString *)videoThumbnail:(NSUInteger)idx {
    return [self videoThumbnailWithVideoId:[self videos][idx]];
}

- (NSString *)videoThumbnailWithVideoId:(NSString *)videoId
{
    if([_srcType isEqualToString:@"0"])
    {
        return [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/1.jpg",videoId];
    }
    else if([_srcType isEqualToString:@"1"])
    {
        return [NSString stringWithFormat:@"http://www.dailymotion.com/thumbnail/160x120/video/%@",videoId];
    }
    else if([_srcType isEqualToString:@"2"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",
                [videoId substringWithRange:NSMakeRange(3, ([videoId length]-2))]];
    }
    else if ([_srcType isEqualToString:@"13"]
             || [_srcType isEqualToString:@"14"]
             || [_srcType isEqualToString:@"15"]
             || [_srcType isEqualToString:@"mthai"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",videoId];
    }
    else
    {
        return @"http://www.makathon.com/placeholder.png";
    }
}

@end
