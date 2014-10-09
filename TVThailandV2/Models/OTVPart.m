//
//  OTVPart.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVPart.h"

@implementation OTVPart

- (NSString *)description {
    return [NSString stringWithFormat:@"partId:%@, nameTh:%@, thumbnail:%@, streamURL:%@ vastURL:%@", _partId, _nameTh, _thumbnail, _streamURL, _vastURL];
}


- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        
        _partId = ([dictionary objectForKey:@"id"] ? [dictionary objectForKey:@"id"] : [NSString string]);
        _nameTh = ([dictionary objectForKey:@"name_th"] ? [dictionary objectForKey:@"name_th"] : [NSString string]);
        _thumbnail = ([dictionary objectForKey:@"thumbnail"] ? [dictionary objectForKey:@"thumbnail"] : [NSString string]);
        if ([_thumbnail isKindOfClass:[NSNull class]]) {
            _thumbnail = [NSString string];
        }
        _streamURL = ([dictionary objectForKey:@"stream_url"] ? [dictionary objectForKey:@"stream_url"] : [NSString string]);
        _mediaCode = ([dictionary objectForKey:@"media_code"] ? [dictionary objectForKey:@"media_code"] : [NSString string]);
    }
    
    return self;
}

- (void)setPartContent:(NSDictionary *)dictionary {
    _partId = ([dictionary objectForKey:@"id"] ? [dictionary objectForKey:@"id"] : [NSString string]);
    _nameTh = ([dictionary objectForKey:@"name_th"] ? [dictionary objectForKey:@"name_th"] : [NSString string]);
    _thumbnail = ([dictionary objectForKey:@"thumbnail"] ? [dictionary objectForKey:@"thumbnail"] : [NSString string]);
    if ([_thumbnail isKindOfClass:[NSNull class]]) {
        _thumbnail = [NSString string];
    }
    _streamURL = ([dictionary objectForKey:@"stream_url"] ? [dictionary objectForKey:@"stream_url"] : [NSString string]);
    _mediaCode = ([dictionary objectForKey:@"media_code"] ? [dictionary objectForKey:@"media_code"] : [NSString string]);
}

@end
