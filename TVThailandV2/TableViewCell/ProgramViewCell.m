//
//  ProgramViewCell.m
//  tvthai
//
//  Created by Nattapong Tonprasert on 11/8/11.
//  Copyright (c) 2011 Makathon Labs. All rights reserved.
//

#import "ProgramViewCell.h"

#import "Three20/Three20.h"

@implementation ProgramViewCell

@synthesize thumbnail;
@synthesize title;
@synthesize detail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.thumbnail unsetImage];
}

@end
