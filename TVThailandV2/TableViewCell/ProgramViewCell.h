//
//  ProgramViewCell.h
//  tvthai
//
//  Created by Nattapong Tonprasert on 11/8/11.
//  Copyright (c) 2011 Makathon Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTImageView;
@interface ProgramViewCell : UITableViewCell
{
//    IBOutlet UIImageView* thumbnail;
    IBOutlet UILabel *title;
    IBOutlet UILabel *detail;
    IBOutlet TTImageView *thumbnail;
}
@property (nonatomic, strong) TTImageView *thumbnail;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *detail;

@end
