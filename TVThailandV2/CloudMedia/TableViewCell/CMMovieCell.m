//
//  CMMovieCell.m
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMMovieCell.h"
#import "CMMovie.h"
#import "UIImageView+AFNetworking.h"

@implementation CMMovieCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        
//        self.descriptionLabel.textAlignment = UITextAlignmentCenter;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureWithCMMovie:(CMMovie *)cmMovie{

    
    self.movieNameLabel.text = cmMovie.thaiName;
    self.movieNameLabel.numberOfLines = 2;
    self.movieNameLabel.frame = CGRectMake(100,5,208,23);
    [self.movieNameLabel sizeToFit];
    [self.movieNameLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    self.descriptionLabel.text = cmMovie.descriptionOfMovie;
    self.descriptionLabel.numberOfLines = 4;
    self.descriptionLabel.frame = CGRectMake(100,44,208,18);
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:cmMovie.imageSmall]];
    if ([cmMovie.status isEqualToString:@"paid"]){
        self.priceLabel.text = [NSString stringWithFormat:@"%@P",cmMovie.price];
    }else if ([cmMovie.status isEqualToString:@"available"]) {
        self.priceLabel.text = @"Available";
    }else if ([cmMovie.status isEqualToString:@"expired"]){
        self.priceLabel.text = [NSString stringWithFormat:@"Expired, Re-Rent %@P",cmMovie.price];
        self.priceLabel.textColor = [UIColor redColor];
    }else if ([cmMovie.status isEqualToString:@"free"]){
        self.priceLabel.text = @"Free";
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"%@P",cmMovie.price];
    }
}




@end
