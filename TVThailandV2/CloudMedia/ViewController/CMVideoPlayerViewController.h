//
//  CMVideoPlayerViewController.h
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCategoryViewController.h"
@class CMEpisode;
@class CMMovie;

typedef enum {
    kMoviePreview = 0,
    kEPPlay = 1,
    kEPPreview = 2
} VIDEOModeType;

@interface CMVideoPlayerViewController : UIViewController

@property (nonatomic , weak) CMEpisode *cmEpisode;
@property (nonatomic , weak) CMMovie *cmMovie;
@property (unsafe_unretained, nonatomic) VIDEOModeType videomode;

@end
