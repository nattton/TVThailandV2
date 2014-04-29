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

- (void)configureWhatsNewWithShow:(Show *)show;
- (void)configureWithShow:(Show *)show;
- (void)configureWithProgram:(Program *)program;
@end
