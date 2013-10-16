
//  CMChangePasswordViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/7/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMChangePasswordViewController.h"
#import "CMUser.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"

@interface CMChangePasswordViewController ()<UIAlertViewDelegate>{
    
}

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *aNewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordField;

@end

@implementation CMChangePasswordViewController

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
	// Do any additional setup after loading the view.
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


- (IBAction)tabOnSubmitButton:(id)sender {
    
    
    NSString *oldpassword = self.oldPasswordField.text;
    NSString *newpassword = self.aNewPasswordField.text;
    NSString *confirmnewpassword = self.confirmNewPasswordField.text;

    //Validate Form
    NSString *validFormResult = [self validateFormWithOldPassward:oldpassword aNewPassword:newpassword conFirmNewPassword:confirmnewpassword];
    if (![validFormResult isEqualToString:@""]) {
        self.warningLabel.text = validFormResult;
        return;
    }
    
    [CMUser changePasswordWithOldPassword:oldpassword aNewPassword:newpassword confirmNewPassword:confirmnewpassword Block:^(BOOL isSuccess, NSString *message, NSError *error) {
        if (isSuccess) {
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Alert"];
            [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
            [dialog setTag:100];
            [dialog addButtonWithTitle:@"Dismiss"];
            
            [dialog show];

        }else{
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Alert"];
            [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
            [dialog addButtonWithTitle:@"Dismiss"];
            
            [dialog show];

        }
    }];
}



-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }

    
}

- (NSString *)validateFormWithOldPassward:(NSString *)oldPassword aNewPassword:(NSString *)aNewPassword conFirmNewPassword:(NSString *)confirmNewPassword{
    if (oldPassword.length < 5) {
        return @"*Old password is too short. Please enter atleast 6 characters";
    }
    if (aNewPassword.length < 5) {
        return @"*New password is too short. Please enter atleast 6 characters";
    }
    if (![confirmNewPassword isEqualToString:aNewPassword]) {
        return @"*Password does not match";
    }
    return @"";
}

@end
