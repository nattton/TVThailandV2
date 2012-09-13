//
//  ProgramInfoViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/8/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTImageView;
@interface ProgramInfoViewController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *detailLabel;
@property (strong, nonatomic) IBOutlet TTImageView *thumbnail;
@property (strong, nonatomic) NSString *program_id;
@property (strong, nonatomic) NSString *program_title;
@end
