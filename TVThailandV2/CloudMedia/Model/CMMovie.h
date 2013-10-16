//
//  CMMovie.h
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMMovie : NSObject

@property   (strong,nonatomic) NSString *idMovie;
@property   (strong,nonatomic) NSString *thaiName;
@property   (strong,nonatomic) NSString *engName;
@property   (strong,nonatomic) NSString *price;
@property   (strong,nonatomic) NSString *period;
@property   (strong,nonatomic) NSString *status;
@property   (strong,nonatomic) NSString *imageSmall;
@property   (strong,nonatomic) NSString *imageLarge;
@property   (strong,nonatomic) NSString *descriptionOfMovie;
@property   (strong,nonatomic) NSString *rtspLink;
@property   (strong,nonatomic) NSString *trailerLink;
@property   (strong,nonatomic) NSString *wishlist;


-(id)initWithID:(NSString *)newIdMovie thaiName:(NSString *)newThaiName engName:(NSString *)newEngName price:(NSString *)newPrice period:(NSString *)newPeriod status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription rtspLink:(NSString *)newRTSPLink trailerLink:(NSString *)newTrailerLink wishList:(NSString *)newWishlist;

+(CMMovie *)cmMovieWithID:(NSString *)newIdMovie thaiName:(NSString *)newThaiName engName:(NSString *)newEngName price:(NSString *)newPrice period:(NSString *)newPeriod status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription rtspLink:(NSString *)newRTSPLink trailerLink:(NSString *)newTrailerLink wishList:(NSString *)newWishlist;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (void)loadCMMovieWithCateID:(NSString *)idOfCate start:(NSUInteger)start Block:(void (^)(NSArray *cmMovies, NSError *error))block;

+ (void)loadCMPurchaseBlock:(void (^)(NSArray *cmMovies, NSError *error))block;

+ (void)loadCMWishlistBlock:(void (^)(NSArray *cmMovies, NSError *error))block;

+ (void)rentMovieWithID:(NSString *)movieID Block:(void (^)(BOOL isSuccess,CMMovie *cmMovie,NSArray *cmEpisodes, NSString *message, NSError *error))block;
+ (void)addToWishlist:(NSString *)movieID Block:(void (^)(BOOL isSuccess,NSString *message,NSError *error))block;
+ (void)removeFromWishlist:(NSString *)movieID Block:(void (^)(BOOL isSuccess,NSString *message,NSError *error))block;

- (BOOL)isWishList;




@end
