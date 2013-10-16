//
//  CMCateCell.h
//  CloudMedia
//
//  Created by April Smith on 9/29/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMCategory;

@interface CMCateCell : UITableViewCell

- (void)configureWithCMCategory:(CMCategory *)cmCategory;

@end
