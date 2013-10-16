//
//  CMMovieViewController.h
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCategoryViewController.h"
@class CMCategory;


typedef enum {
    kMovie = 0,
    kPurchase = 1,
    kWishlist = 2
} MovieModeType;

@interface CMMovieViewController : UIViewController

@property (strong, nonatomic) CMCategory *cmCategory;
@property (unsafe_unretained, nonatomic) MovieModeType mode;

@end
