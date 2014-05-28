//
//  RadioTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 5/23/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Radio.h"

@interface RadioTableViewCell () 

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailOfStation;
@property (weak, nonatomic) IBOutlet UILabel *nameOfStation;

@end

@implementation RadioTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self roundImage];
}

- (void)roundImage {

//    self.thumbnailOfStation.layer.shadowColor = [UIColor grayColor].CGColor;
//    self.thumbnailOfStation.layer.shadowOffset = CGSizeMake(0, 0.5);
//    self.thumbnailOfStation.layer.shadowOpacity = 1;
//    self.thumbnailOfStation.layer.shadowRadius = 1;
    self.thumbnailOfStation.layer.cornerRadius = 2.0;
    self.thumbnailOfStation.clipsToBounds = YES;
}

-(void)configureWithRadio:(Radio *)radio {
    
    self.nameOfStation.text = radio.title;
    [self.thumbnailOfStation setImageWithURL:[NSURL URLWithString:radio.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder_hi"]];
    
}

@end
