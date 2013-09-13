//
//  ProgramTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ProgramTableViewCell.h"
#import "ProgramObj.h"

#import "UIImageView+AFNetworking.h"

@implementation ProgramTableViewCell {
@private
    __strong ProgramObj *_program;
}

@synthesize program = _program;

@synthesize titleTextLabel = _titleTextLabel;
@synthesize descriptionTextLabel = _descriptionTextLabel;
@synthesize thumbnailImageView = _thumbnailImageView;

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

//- (void)setProgram:(ProgramObj *)program {
//    _program = program;
//    self.titleTextLabel.text = _program.title;
//    self.descriptionTextLabel.text = _program.description;
//    [self.thumbnailImageView setImageWithURL:_program.imageURL placeholderImage:[UIImage imageNamed:@"Icon"]];
//    
//    [self setNeedsLayout];
//}
//
//+ (CGFloat)heightForCellWithPost:(ProgramObj *)program {
//    CGSize sizeToFit = [program.description sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
//    
//    return fmaxf(70.0f, sizeToFit.height + 45.0f);
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.thumbnailImageView.frame = CGRectMake(10.0f, 10.0f, 50.0f, 50.0f);
//    self.titleTextLabel.frame = CGRectMake(70.0f, 10.0f, 240.0f, 20.0f);
//    
//    CGRect detailTextLabelFrame = CGRectOffset(self.detailTextLabel.frame, 0.0f, 25.0f);
//    detailTextLabelFrame.size.height = [[self class] heightForCellWithPost:_program] - 45.0f;
//    self.descriptionTextLabel.frame = detailTextLabelFrame;
//}

@end
