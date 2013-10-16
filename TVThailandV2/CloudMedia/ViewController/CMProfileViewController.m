//
//  CMProfileViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/5/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMProfileViewController.h"
#import "CMUser.h"
@interface CMProfileViewController ()

@end

@implementation CMProfileViewController{
    CMUser *cmUser;
}

static NSString *cmEditProfileSegue = @"CMEditProfileSegue";
static NSString *cmAddCreditSegue = @"CMAddCreditSegue";
static NSString *cmChangePasswordSegue = @"CMChangePasswordSegue";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cmUser = [CMUser sharedInstance];
    [self refreshUI];

}

- (void)viewWillAppear:(BOOL)animated{
    
    [CMUser loadUserProfile:cmUser.memberId Block:^(BOOL isSuccess, NSError *error) {
        if (!isSuccess) {
            UIAlertView* dialogAlertRentSuccess = [[UIAlertView alloc] init];
            [dialogAlertRentSuccess setDelegate:self];
            [dialogAlertRentSuccess setMessage:@"Sorry,User profile cannot be updated now"];
            [dialogAlertRentSuccess addButtonWithTitle:@"Dismiss"];
            [dialogAlertRentSuccess show];
        }else{
            [self refreshUI];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tabOnCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)tabOnAddCreditButton:(id)sender {
    [self performSegueWithIdentifier:cmAddCreditSegue sender:nil];
}
- (IBAction)tabOnEditProfileButton:(id)sender {
    [self performSegueWithIdentifier:cmEditProfileSegue sender:nil];
}
- (IBAction)tabOnChangePasswordButton:(id)sender {
    [self performSegueWithIdentifier:cmChangePasswordSegue sender:nil];
}
- (IBAction)tabOnLogoutButton:(id)sender {
    //Clear data from NSUserD
    [self logout];
}

- (void)logout{
    
    [[CMUser sharedInstance] clear];
    NSLog(@"Successfully Log out.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshUI{
    self.userNameLabel.text = cmUser.userName;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",cmUser.firstName,cmUser.lastName];
    self.emailLabel.text = cmUser.email;
    self.creditAmountLabel.text = [NSString stringWithFormat:@"%@ P",cmUser.creditAmount] ;
    self.sexLabel.text = cmUser.sex;
    self.birthdateLabel.text = cmUser.birthDate;
    self.telephoneNumberLabel.text = cmUser.tel;
}

@end
