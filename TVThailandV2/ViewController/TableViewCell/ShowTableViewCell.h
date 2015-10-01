//
//  ShowTableViewCell.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;
@class Program;
@interface ShowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageThumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (void)configureWhatsNewWithShow:(Show *)show;
- (void)configureWithShow:(Show *)show;
- (void)configureWithProgram:(Program *)program;
@end
