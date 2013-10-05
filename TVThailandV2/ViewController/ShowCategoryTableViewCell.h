//
//  GenreTableViewCell.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowCategory;
@interface ShowCategoryTableViewCell : UITableViewCell

//- (void)configureAllGenre;
- (void)configureWithGenre:(ShowCategory *)genre;

@end
