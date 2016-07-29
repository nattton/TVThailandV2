//
//  OTVShow.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShow.h"
#import "AFHTTPSessionManager.h"

@implementation OTVShow

- (NSString *)description {
    return [NSString stringWithFormat:@"idShow:%@, title:%@, detail:%@, thumbnail%@", self.idShow, self.title, self.detail, self.thumbnail];
//    return [NSString stringWithFormat:@"idShow:%@, title:%@, detail:%@", self.idShow, self.title, self.detail];
}

- (id) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        _idShow = ([dictionary objectForKey:@"id"]?[dictionary objectForKey:@"id"]:[NSString string]);
        _title = ([dictionary objectForKey:@"name_th"]?[dictionary objectForKey:@"name_th"]:[NSString string]);
        _detail = ([dictionary objectForKey:@"detail"]?[dictionary objectForKey:@"detail"]:[NSString string]);
        _thumbnail = ([dictionary objectForKey:@"thumbnail"]?[dictionary objectForKey:@"thumbnail"]:[NSString string]);
        if ([_thumbnail isKindOfClass:[NSNull class]]) {
            _thumbnail = [NSString string];
        }
    }
    return self;
}

+ (void)retrieveData:(NSString *)categoryName Start:(NSInteger)start Block:(void (^)(NSArray *otvShows, NSError *error)) block {
    NSString *url = [NSString stringWithFormat:@"%@/%@/index/%@/%@/%@/%@/50/", kOTV_URL_BASE, categoryName, kOTV_APP_ID, kAPP_VERSION, kOTV_API_VERSION, [[NSNumber numberWithInteger:start] stringValue]];
    NSString  *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:currentDeviceId forHTTPHeaderField:@"X-Device-ID"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *jShows = [responseObject valueForKeyPath:@"items"];
        NSMutableArray *mutableShows = [NSMutableArray arrayWithCapacity:[jShows count]];
        
        for (NSDictionary *dictShow in jShows) {
            OTVShow * show = [[OTVShow alloc] initWithDictionary:dictShow];
            [mutableShows addObject:show];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableShows], nil);
        }
    } failure:^(NSURLSessionTask * _Nonnull operation, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array], error);
            
            DLog(@"failure load OTVShow: %@", error);
        }
    }];
}

@end
