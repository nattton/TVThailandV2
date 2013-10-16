//
//  CMEpisode.h
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMEpisode : NSObject

@property   (strong,nonatomic) NSString *idEpiosde;
@property   (strong,nonatomic) NSString *thaiName;
@property   (strong,nonatomic) NSString *engName;
@property   (strong,nonatomic) NSString *status;
@property   (strong,nonatomic) NSString *imageSmall;
@property   (strong,nonatomic) NSString *imageLarge;
@property   (strong,nonatomic) NSString *descriptionOfEpisode;
@property   (strong,nonatomic) NSString *videoLink;
@property   (strong,nonatomic) NSString *trailerLink;


-(id)initWithID:(NSString *)newIdEpisode thaiName:(NSString *)newThaiName engName:(NSString *)newEngName status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription videoLink:(NSString *)newVideoLink trailerLink:(NSString *)newTrailerLink;

+(CMEpisode *)cmEpisodeWithID:(NSString *)newIdEpisode thaiName:(NSString *)newThaiName engName:(NSString *)newEngName  status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription videoLink:(NSString *)newVideoLink trailerLink:(NSString *)newTrailerLink;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (void)loadCMEpWithMovieID:(NSString *)idOfMovie start:(NSUInteger)start Block:(void (^)(NSArray *cmEpisodes, NSError *error))block;



@end
