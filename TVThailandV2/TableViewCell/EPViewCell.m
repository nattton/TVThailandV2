//
//  EPViewCell.m
//  TV_Thailand
//
//  Created by Nattapong Tonprasert on 12/22/11.
//  Copyright (c) 2011 luciferultram@gmail.com. All rights reserved.
//

#import "EPViewCell.h"
#import "Three20/Three20.h"

@implementation EPViewCell

@synthesize thumbnail;
@synthesize title;

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