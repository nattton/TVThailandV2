//
//  CMEpisode.m
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMEpisode.h"
#import "CMApiClient.h"
#import "CMUser.h"

@implementation CMEpisode

-(id)initWithID:(NSString *)newIdEpisode thaiName:(NSString *)newThaiName engName:(NSString *)newEngName status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription videoLink:(NSString *)newVideoLink trailerLink:(NSString *)newTrailerLink{
    
    self = [super init];
    if (self) {
        
        self.idEpiosde = newIdEpisode;
        self.thaiName = newThaiName;
        self.engName = newEngName;
        self.status = newStatus;
        self.imageSmall = newImageSmall;
        self.imageLarge = newImageLarge;
        self.descriptionOfEpisode = newDescription;
        self.videoLink = newVideoLink;
        self.trailerLink = newTrailerLink;
       
    }
     return self;
}

+(CMEpisode *)cmEpisodeWithID:(NSString *)newIdEpisode thaiName:(NSString *)newThaiName engName:(NSString *)newEngName  status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription videoLink:(NSString *)newVideoLink trailerLink:(NSString *)newTrailerLink{
    
    return [[CMEpisode alloc]initWithID:newIdEpisode thaiName:newThaiName engName:newEngName status:newStatus imageSmall:newImageSmall imageLarge:newImageLarge description:newDescription videoLink:newVideoLink trailerLink:newTrailerLink];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"idMovie:%@, thaiName:%@, engName:%@, status:%@, imageSmall:%@, imageLarge:%@, description:%@, videoLink:%@, trailerLink:%@" ,self.idEpiosde, self.thaiName,self.engName,self.status,self.imageSmall,self.imageLarge,self.descriptionOfEpisode,self.videoLink,self.trailerLink];
}

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _idEpiosde = [dictionary objectForKey:@"id"];
        _thaiName  = [dictionary objectForKey:@"thaiName"];
        _engName = [dictionary objectForKey:@"engName"];
        _status = [dictionary objectForKey:@"status"];
        _imageSmall = [dictionary objectForKey:@"imageHolderSmall"];
        _imageLarge = [dictionary objectForKey:@"imageHolderLarge"];
        _descriptionOfEpisode = [dictionary objectForKey:@"description"];
        _videoLink = [dictionary objectForKey:@"iosLink"];
        _trailerLink = [dictionary objectForKey:@"trailerLink"];
    }
    return self;
}
+ (void)loadCMEpWithMovieID:(NSString *)idOfMovie start:(NSUInteger)start Block:(void (^)(NSArray *cmEpisodes, NSError *error))block{

    NSString *cmMemberID = @"";
    CMUser *cmUser = [CMUser sharedInstance];
    
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
        cmMemberID = [NSString stringWithFormat:@"&memberId=%@",cmUser.memberId];
    }
    [client getPath:[NSString stringWithFormat:@"ticketmovies/movies/%@?item=%d%@",idOfMovie,start,cmMemberID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *episodes = responseObject;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:episodes.count];
        NSLog(@"loadCMEpWithMovieID------------%@",responseObject);
        for (NSDictionary *episode in episodes) {
            CMEpisode *cmEpisode = [[CMEpisode alloc]initWithDictionary:episode];
            [temp addObject:cmEpisode];

        }
        if (block) {
            block([NSArray arrayWithArray:temp], nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
            NSLog(@"failure loadCMMovieWithCateID");
        }
    }];
    
}




@end
