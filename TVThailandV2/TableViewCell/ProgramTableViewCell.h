//
//  ProgramTableViewCell.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgramObj;
@interface ProgramTableViewCell : UITableViewCell

@property (nonatomic, strong) ProgramObj *program;

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionTextLabel;

+ (CGFloat)heightForCellWithPost:(ProgramObj *)program;

@end
