//
//  CMCategory.m
//  CloudMedia
//
//  Created by April Smith on 9/29/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCategory.h"
#import "CMApiClient.h"
#import "CMUser.h"

@implementation CMCategory

-(id) initWithidOfCM:(NSString *)newID title:(NSString *)newTitle description:(NSString *)newDescription thumbnail:(NSString *)newThumbnail{
    self = [super init];
    if (self) {
        self.idCM = newID;
        self.title = newTitle;
        self.descriptionOfCM = newDescription;
        self.thumbnail = newThumbnail;
    }
    return self;
}

+(CMCategory *)categoryWithidOfCM:(NSString *)newID
                            title:(NSString *)newTitle
                      description:(NSString *)newDescription
                        thumbnail:(NSString *)newThumbnail{
    return [[CMCategory alloc]initWithidOfCM:newID title:newTitle description:newDescription thumbnail:newThumbnail];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"id:%@, title:%@, description:%@, thumbnail:%@",self.idCM, self.title,self.descriptionOfCM,self.thumbnail];
}


- (id)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    if (self) {
        _idCM = [dictionary objectForKey:@"id"];
        _title = [dictionary objectForKey:@"title"];
        _descriptionOfCM = [dictionary objectForKey:@"description"];
        _thumbnail = [dictionary objectForKey:@"thumbnail"];
    }
    return self;
}

+ (void)loadCMCategory:(NSUInteger)start Block:(void (^)(NSArray *cmCategories, NSError *error))block{

    CMUser *cmUser = [CMUser sharedInstance];
    
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0 ) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }
    
    [client getPath:[NSString stringWithFormat:@"moviecategorys?item=%d",start] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *categories = responseObject;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:categories.count];
        for (NSDictionary *category in categories) {
            CMCategory *cmCategory = [[CMCategory alloc]initWithDictionary:category];
            [temp addObject:cmCategory];

        }
        if (block) {
            block([NSArray arrayWithArray:temp], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
             NSLog(@"failure loadCMCategory");
        }
    }];
    
    
}

@end
