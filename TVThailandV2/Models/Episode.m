//
//  Episode.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "Episode.h"
#import "AFMakathonClient.h"
#import "Show.h"

#import "Base64.h"

@implementation Episode {
    NSString *_titleDisplay;
    NSArray *_videos;
}
- (id)initWithDictionary:(NSDictionary *)dictionary {
    return [self initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary thumbnail:(NSString *)thumbnailURL; {
    self = [super init];
    if (self) {
        _Id = [dictionary objectForKey:@"id"];
        _ep = [[dictionary objectForKey:@"ep"] intValue];
        _title = [dictionary objectForKey:@"title"];
        _videoEncrypt = [dictionary objectForKey:@"video_encrypt"];
        _srcType = [dictionary objectForKey:@"src_type"];
        _viewCount = [dictionary objectForKey:@"view_count"];
        _parts = [dictionary objectForKey:@"parts"];
        _password = [dictionary objectForKey:@"pwd"];
        
        NSDateFormatter *_df = [[NSDateFormatter alloc] init];
        NSDateFormatter *_thaiFormat = [[NSDateFormatter alloc] init];
        NSNumberFormatter *_numberFormatter = [[NSNumberFormatter alloc] init];
        
        [_df setDateFormat:@"yyyy-MM-dd"];
        [_thaiFormat setDateFormat:@"dd MMMM yyyy"];
        [_thaiFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th"]];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        _updatedDate = [NSString stringWithFormat:@"ออกอากาศ %@",
                 [_thaiFormat stringFromDate:[_df dateFromString: [dictionary objectForKey:@"date"]]]];
        _viewCount = [NSString stringWithFormat:@"%@ views",
                      [_numberFormatter stringFromNumber:[NSNumber numberWithInt:[[dictionary objectForKey:@"view_count"] intValue]]]];
        
        _defaultThumbnail = thumbnailURL; 
    }
    return self;
}

+ (void)retrieveDataWithId:(Show *)show Start:(NSUInteger)start Block:(void (^)(Show *show, NSArray *episodes, NSError *error))block {
    
    if (!show) return;
    
    NSString *url = [NSString stringWithFormat:@"api2/episode/%@/%@?device=ios&version=%@&build=%@", show.Id, [[NSNumber numberWithInteger:start] stringValue] , kAPP_VERSION, kAPP_BUILD];
    [[AFMakathonClient sharedClient] GET:url parameters:nil progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        Show *showInfo;
        id dictInfo = [responseObject valueForKey:@"info"];
        NSDictionary *dictShow = [dictInfo isKindOfClass:[NSDictionary class]] ? dictInfo : nil;
        if (dictShow) {
            showInfo = [[Show alloc] initWithDictionary:dictShow];
        } else {
            showInfo = show;
        }
        
        NSArray *episodes = [responseObject valueForKeyPath:@"episodes"];
        NSMutableArray *mutableEpisodes = [NSMutableArray arrayWithCapacity:[episodes count]];
        for (NSDictionary *dict in episodes) {
            Episode *episode = [[Episode alloc] initWithDictionary:dict thumbnail:show.thumbnailUrl];
            [mutableEpisodes addObject:episode];
        }
        
        if (block) {
            block(showInfo, [NSArray arrayWithArray:mutableEpisodes], nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block(nil, [NSArray array], error);
        }
    }];
}


- (void)sendViewEpisode {
    NSString *url = [NSString stringWithFormat:@"api2/view_episode/%@?device=ios&version=%@&build=%@", self.Id, kAPP_VERSION, kAPP_BUILD];
    [[AFMakathonClient sharedClient] GET:url parameters:nil progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
}

-(NSString *)titleDisplay {
    if (_titleDisplay == nil) {
        NSMutableString *display = [NSMutableString string];
        if (_ep > 20000000) {
            if ([_title isEqualToString:@""]) {
                [display appendString:_updatedDate];
            } else {
                [display appendString:_title];
            }
        } else {
            [display appendFormat:@"ตอนที่ %@", [[NSNumber numberWithInteger:_ep] stringValue]];
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
                                stringByReplacingOccurrencesOfString:@"_" withString:@"/"]
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
    if([_srcType isEqualToString:@"0"]) {
        return [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/0.jpg",videoId];
    }
    else if([_srcType isEqualToString:@"1"]) {
        return [NSString stringWithFormat:@"http://www.dailymotion.com/thumbnail/video/%@",videoId];
    }
    else if([_srcType isEqualToString:@"2"]) {
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",
                [videoId substringWithRange:NSMakeRange(3, ([videoId length]-2))]];
    }
    else if ([_srcType isEqualToString:@"13"]
             || [_srcType isEqualToString:@"14"]
             || [_srcType isEqualToString:@"15"]
             || [_srcType isEqualToString:@"mthai"]) {
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",videoId];
    }
    
    return _defaultThumbnail;
}

@end
