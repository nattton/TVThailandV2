//
//  ProgramListViewCell.h
//  tvthai
//
//  Created by Nattapong Tonprasert on 11/8/11.
//  Copyright (c) 2011 Makathon Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramListViewCell : UITableViewCell
{
    IBOutlet UILabel *name;
    IBOutlet UILabel *date;
    IBOutlet UILabel *view;
}
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UILabel *view;
@end
