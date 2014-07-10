//
//  OTVPart.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTVPart : NSObject

@property (nonatomic, readonly) NSString *partId;
@property (nonatomic, readonly) NSString *nameTh;
@property (nonatomic, readonly) NSString *nameEn;
@property (nonatomic, readonly) NSString *thumbnail;
@property (nonatomic, readonly) NSString *cover;
@property (nonatomic, readonly) NSString *streamURL;
@property (nonatomic, strong) NSString *vastURL;
@property (nonatomic, readonly) NSString *mediaCode;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)setPartContent:(NSDictionary *)dictionary;

@end
