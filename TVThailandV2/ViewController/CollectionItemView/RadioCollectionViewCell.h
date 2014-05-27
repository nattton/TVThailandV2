//
//  RadioCollectionViewCell.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/27/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Radio;
@interface RadioCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)configureWithRadio:(Radio *)radio;
@end
