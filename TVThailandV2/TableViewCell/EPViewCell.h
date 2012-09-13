//
//  EPViewCell.h
//  TV_Thailand
//
//  Created by Nattapong Tonprasert on 12/22/11.
//  Copyright (c) 2011 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTImageView;
@interface EPViewCell : UITableViewCell
{
    IBOutlet TTImageView* thumbnail;
    IBOutlet UILabel *title;
}
@property (nonatomic, strong) TTImageView *thumbnail;
@property (nonatomic, strong) UILabel *title;

@end