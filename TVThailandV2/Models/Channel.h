//
//  Channel.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/2/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *thumbnailUrl;
@property (nonatomic, readonly) NSString *videoUrl;
@property (nonatomic, readonly) NSString *isHasEp;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)retrieveData:(void (^)(NSArray *channels ,NSError *error))block;

@end
