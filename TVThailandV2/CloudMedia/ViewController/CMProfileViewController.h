//
//  CMProfileViewController.h
//  CloudMedia
//
//  Created by April Smith on 10/5/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

@property (weak, nonatomic) IBOutlet UILabel *telephoneNumberLabel;

@end
