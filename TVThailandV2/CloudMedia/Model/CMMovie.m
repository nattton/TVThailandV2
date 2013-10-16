//
//  CMMovie.m
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMMovie.h"
#import "CMApiClient.h"
#import "CMUser.h"
#import "AFJSONRequestOperation.h"
#import "CMEpisode.h"


@implementation CMMovie

-(id)initWithID:(NSString *)newIdMovie thaiName:(NSString *)newThaiName engName:(NSString *)newEngName price:(NSString *)newPrice period:(NSString *)newPeriod status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription rtspLink:(NSString *)newRTSPLink trailerLink:(NSString *)newTrailerLink wishList:(NSString *)newWishlist{
    self = [super init];
    if (self) {
        self.idMovie = newIdMovie;
        self.thaiName = newThaiName;
        self.engName = newEngName;
        self.price = newPrice;
        self.period = newPeriod;
        self.status = newStatus;
        self.imageSmall = newImageSmall;
        self.imageLarge = newImageLarge;
        self.descriptionOfMovie = newDescription;
        self.rtspLink = newRTSPLink;
        self.trailerLink = newTrailerLink;
        self.wishlist = newWishlist;
    }
    return self;
}

+(CMMovie *)cmMovieWithID:(NSString *)newIdMovie thaiName:(NSString *)newThaiName engName:(NSString *)newEngName price:(NSString *)newPrice period:(NSString *)newPeriod status:(NSString *)newStatus imageSmall:(NSString *)newImageSmall imageLarge:(NSString *)newImageLarge description:(NSString *)newDescription rtspLink:(NSString *)newRTSPLink trailerLink:(NSString *)newTrailerLink wishList:(NSString *)newWishlist{

    return [[CMMovie alloc]initWithID:newIdMovie thaiName:newThaiName engName:newEngName price:newPrice period:newPeriod status:newStatus imageSmall:newImageSmall imageLarge:newImageLarge description:newDescription rtspLink:newRTSPLink trailerLink:newTrailerLink wishList:newWishlist];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"idMovie:%@, thaiName:%@, engName:%@, price:%@, period:%@, status:%@, imageSmall:%@, imageLarge:%@, description:%@, rtspLink:%@, trailerLink:%@, wishlish:%@ " ,self.idMovie, self.thaiName,self.engName,self.price,self.period,self.status,self.imageSmall,self.imageLarge,self.descriptionOfMovie,self.rtspLink,self.trailerLink,self.wishlist];
}

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
//        NSLog(@"##### initWithDictionary %@", dictionary);
        _idMovie = [dictionary objectForKey:@"id"];
        _thaiName  = [dictionary objectForKey:@"thaiName"];
        _engName = [dictionary objectForKey:@"engName"];
        _price = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"price"]];
        _period = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"period"]];
        _status = [dictionary objectForKey:@"status"];
        _imageSmall = [dictionary objectForKey:@"imageHolderSmall"];
        _imageLarge = [dictionary objectForKey:@"imageHolderLarge"];
        _descriptionOfMovie = [dictionary objectForKey:@"description"];
        _rtspLink = [dictionary objectForKey:@"rtspLink"];
        _trailerLink = [dictionary objectForKey:@"trailerLink"];
        _wishlist = [dictionary objectForKey:@"wishlist"];

    }
    return self;
    
}
+ (void)loadCMMovieWithCateID:(NSString *)idOfCate start:(NSUInteger)start Block:(void (^)(NSArray *cmMovies, NSError *error))block{

    NSString *cmMemberID = @"";
    CMUser *cmUser = [CMUser sharedInstance];

    
    CMApiClient *client = [CMApiClient sharedInstance];

    if (cmUser.token && cmUser.token.length > 0) {

        [client setDefaultHeader:@"token" value:cmUser.token];
        cmMemberID = [NSString stringWithFormat:@"&memberId=%@",cmUser.memberId];
    }
    [client getPath:[NSString stringWithFormat:@"ticketmovies/category/%@?item=%d%@",idOfCate,start,cmMemberID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"loadCMMovieWithCateID------------%@",responseObject);
        NSArray *movies = responseObject;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:movies.count];
        for (NSDictionary *movie in movies) {
            CMMovie *cmMovie = [[CMMovie alloc]initWithDictionary:movie];
            [temp addObject:cmMovie];
           
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

+ (void)loadCMPurchaseBlock:(void (^)(NSArray *, NSError *))block{
    CMUser *cmUser = [CMUser sharedInstance];
    NSString *path = [NSString stringWithFormat:@"userprofiles/movies/%@",cmUser.memberId];
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }
    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *movies = responseObject;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:movies.count];
        for (NSDictionary *movie in movies) {
            CMMovie *cmMovie = [[CMMovie alloc]initWithDictionary:movie];
            [temp addObject:cmMovie];
//            NSLog(@"%@",cmMovie);
        }
        if (block) {
            block([NSArray arrayWithArray:temp], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
            NSLog(@"failure loadCMPurchaseBlock");
        }
    }];
    

}


+ (void)loadCMWishlistBlock:(void (^)(NSArray *, NSError *))block{
    CMUser *cmUser = [CMUser sharedInstance];
    NSString *path = [NSString stringWithFormat:@"wishlists/userprofile/%@",cmUser.memberId];
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }
    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *movies = responseObject;
        NSLog(@"%@",responseObject);
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:movies.count];
        for (NSDictionary *movie in movies) {
            CMMovie *cmMovie = [[CMMovie alloc]initWithDictionary:movie];
            [temp addObject:cmMovie];
            NSLog(@"%@",cmMovie);
        }
        if (block) {
            block([NSArray arrayWithArray:temp], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
            NSLog(@"failure loadCMPurchaseBlock");
        }
    }];
}

+ (void)rentMovieWithID:(NSString *)movieID Block:(void (^)(BOOL isSuccess,CMMovie *cmMovie,NSArray *cmEpisodes, NSString *message, NSError *error))block{
    
    CMUser *cmUser = [CMUser sharedInstance];
    NSDictionary *params = @{@"ticketId":movieID,@"memberId":cmUser.memberId};
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0 ) {
        [client setDefaultHeader:@"token" value:cmUser.token];
        
    }else{
        block(NO,nil,nil,@"Fail to rent movie, please try logout and login again",nil);
        return;
    }
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"buyticket/buy/" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSLog(@"rentMovieWithID----------%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 NSLog(@"Rent Successfully");
                                                 CMMovie *cmMovie = [[CMMovie alloc]initWithDictionary:[JSON objectForKey:@"movie"]];
                                                 NSArray *episodes = [[JSON objectForKey:@"movie"] objectForKey:@"movies"];
                                                 NSMutableArray *temp = [NSMutableArray arrayWithCapacity:episodes.count];
                                                 for (NSDictionary *episode in episodes) {
                                                     CMEpisode *cmEpisode = [[CMEpisode alloc]initWithDictionary:episode];
                                                     [temp addObject:cmEpisode];
                                                 }
                                                 block(YES,cmMovie,[NSArray arrayWithArray:temp], @"Rent Successfully", nil);
                                             }else{
                                                 NSString *message = [NSString stringWithFormat:@"Rent not success: %@",[JSON objectForKey:@"description"]];
                                                 block(NO,nil ,nil,message, nil);
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             
                                             if (block) {
                                                 NSLog(@"NSError: %@",error.localizedDescription);
                                                 block(NO,nil,nil, @"Error", error);
                                             }
                                         }];
    
    [operation start];

}


+ (void)addToWishlist:(NSString *)movieID Block:(void (^)(BOOL isSuccess,NSString *message,NSError *error))block{
    
    CMUser *cmUser = [CMUser sharedInstance];
    NSDictionary *params = @{@"ticketId":movieID,@"memberId":cmUser.memberId};
    NSString *path = [NSString stringWithFormat:@"wishlists"];
    CMApiClient *client = [CMApiClient sharedInstance];
    [client setParameterEncoding:AFJSONParameterEncoding];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }else{
        block(NO,@"Fail to add wishlist, please try logout and login again",nil);
        return;
    }
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:path parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 block(YES,[JSON objectForKey:@"description"],nil);
                                                 
                                             }else{
                                                 block(NO,[JSON objectForKey:@"description"],nil);
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             if (block) {
                                                 block(NO,[JSON objectForKey:@"description"],error);
                                             }
                                         }];
    
    [operation start];
}
+ (void)removeFromWishlist:(NSString *)movieID Block:(void (^)(BOOL isSuccess,NSString *message,NSError *error))block{
    CMUser *cmUser = [CMUser sharedInstance];
    NSDictionary *params = @{@"ticketId":movieID,@"memberId":cmUser.memberId};
    NSString *path = [NSString stringWithFormat:@"wishlists/delete"];
    CMApiClient *client = [CMApiClient sharedInstance];
    [client setParameterEncoding:AFJSONParameterEncoding];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }else{
        block(NO,@"Fail to remove wishlist, please try logout and login again",nil);
        return;
    }
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:path parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 
                                                 block(YES,[JSON objectForKey:@"description"],nil);
                                             }else{

                                                 block(NO,[JSON objectForKey:@"description"],nil);
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                              NSLog(@"NSError: %@",error.localizedDescription);
                                              block(NO,[JSON objectForKey:@"description"],error);
                                         }];
    
    [operation start];
}

- (BOOL)isWishList{
    if ([_wishlist isEqualToString:@"1"]) {
        NSLog(@"isWishlist = TRUE");
        return TRUE;
    }else{
        NSLog(@"isWishlist = FALSE");
        return FALSE;
    }
    return FALSE;
}

@end
