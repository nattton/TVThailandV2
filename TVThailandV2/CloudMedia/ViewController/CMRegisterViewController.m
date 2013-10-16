//
//  CMRegisterViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/4/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMRegisterViewController.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"
#import "CMUser.h"

@interface CMRegisterViewController ()<UIAlertViewDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *telephoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailField;

@end

@implementation CMRegisterViewController{
    UITextField *alertOTPTextField;
    NSString *otpStr;
    NSString *referenceIDStr;
    NSString *regIDStr;
}




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
- (IBAction)tabOnRegisterButton:(id)sender {
//    [self signup];
    NSString *username = self.usernameField.text;
    NSString *tel = self.telephoneField.text;
    NSString *email = self.emailField.text;
    NSString *confirmEmail = self.confirmEmailField.text;
    
    //Validate Form
    NSString *validFormResult = [self validateFormWithUser:username tel:tel email:email confirmEmail:confirmEmail];
    if (![validFormResult isEqualToString:@""]) {
        self.warningLabel.text = validFormResult;
        return;
    }
    
    NSLog(@"SignUP username:%@, tel:%@, email:%@, confirmEmail:%@",username,tel,email,confirmEmail);
    [CMUser registerWithUsername:username tel:tel email:email Block:^(BOOL isSuccess, NSString *referenceID, NSString *regID, NSString *message, NSError *error) {
        
        if (isSuccess) {
            referenceIDStr = referenceID;
            regIDStr = regID;
            
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Enter OTP code"];
            [dialog setMessage:[NSString stringWithFormat:@"%@ \n Ref: %@",message,referenceID]];
            [dialog addButtonWithTitle:@"Cancel"];
            [dialog addButtonWithTitle:@"OK"];
            dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertOTPTextField = [dialog textFieldAtIndex:0];
            alertOTPTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertOTPTextField.placeholder = @"Enter OTP";
            
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
    
    //u need to change 0 to other value(,1,2,3) if u have more buttons.then u can check which button was pressed.
    
    if (buttonIndex == 0) {
        //Cancel Button

    }
    if (buttonIndex == 1){
        //Ok Button
        otpStr = alertOTPTextField.text;
        NSLog(@"OTP:%@, ReferenceID:%@, RegID:%@",otpStr,referenceIDStr,regIDStr);

        [self confirmOTP:otpStr referenceID:referenceIDStr regID:regIDStr];
   
    }
}

-(void)confirmOTP:(NSString *)otp referenceID:(NSString *)refID regID:(NSString *)regID{
    
    if (otp.length==0) {
        self.warningLabel.text = @"Please input OTP";
        return;
    }
    [CMUser registerConfirmWihtOTP:otp referenceID:refID regID:regID Block:^(BOOL isSuccess, NSString *message, NSError *error) {
        if (isSuccess) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                
            }];
            
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

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (NSString *)validateFormWithUser:(NSString *)username tel:(NSString *)tel email:(NSString *)email confirmEmail:(NSString *)confirmEmail {
    if (username.length<5) {
        return @"*Username is too short. Please enter atleast 6 characters";
    }
    if (tel.length<9) {
        return @"*Telephone number is too short. Please enter atleast 10 characters";
    }
    if (email.length<5) {
        return @"*Email is too short. Please enter atleast 6 characters";
    }
    if (![self validateEmailWithString:email]) {
        return @"*Email is not a valid type";
    }
    if (![confirmEmail isEqualToString:email]) {
        return @"*Email does not match";
    }
    
    return @"";
}


@end
