//
//  CMEditProfileViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/7/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMEditProfileViewController.h"
#import "CMUser.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"
#import "SVProgressHUD.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface CMEditProfileViewController ()<UIAlertViewDelegate, UITextFieldDelegate>{
    
}


@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *telephoneField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegment;
@property (weak, nonatomic) IBOutlet UITextField *birthdateField;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;



@end

@implementation CMEditProfileViewController
{
    CMUser *cmUser;
    NSString *_sex;
    NSString *_otp;
    NSString *_referenceID;
    UITextField *_alertOTPTextField;
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
    [self.scrollView contentSizeToFit];
    [super viewDidLoad];
    
    cmUser = [CMUser sharedInstance];
    self.usernameLabel.text = cmUser.userName;
    self.firstnameField.text = cmUser.firstName;
    self.lastnameField.text = cmUser.lastName;
    
    self.emailField.text = cmUser.email;
    self.telephoneField.text = cmUser.tel;
    if ([cmUser.sex isEqualToString:@"Male"]) {
        [self.sexSegment setSelectedSegmentIndex:0];
    }
    if ([cmUser.sex isEqualToString:@"Female"]) {
        [self.sexSegment setSelectedSegmentIndex:1];
    }
    
    if(![cmUser.birthDate isEqualToString:@"0-0-0"]){
        [self.birthdateField setText:cmUser.birthDate];
    }
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.birthdateField setInputView:datePicker];
    

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM/dd/yyy"];
//    [self.birthdateField setText:[dateFormatter stringFromDate:datePicker.date]];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] init];
    accessoryView.barStyle = UIBarStyleBlack;
    accessoryView.translucent = YES;
    accessoryView.tintColor = nil;
    [accessoryView sizeToFit];
    UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(pickerDoneClicked:)];
    [accessoryView setItems:[NSArray arrayWithObjects:spacer,doneButton, nil]];
    
    self.birthdateField.inputAccessoryView = accessoryView;
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

- (IBAction)changeSexSegment:(id)sender {
    if(self.sexSegment.selectedSegmentIndex == 0){
        //Male
        _sex = @"Male";
    }
    if(self.sexSegment.selectedSegmentIndex == 1){
        //Female
        _sex = @"Female";
    }
}


-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.birthdateField.inputView;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    self.birthdateField.text = [dateFormatter stringFromDate:picker.date];
   
}

- (IBAction)pickerDoneClicked:(id)sender {
    [self.birthdateField resignFirstResponder];
}


- (IBAction)tabOnUpdateButton:(id)sender {

    [self requestOTPForUpdateProfile];
    
}

- (NSString *)validateFormWithTel:(NSString *)tel email:(NSString *)email {
    if (tel.length<9) {
        return @"*Please correct Telephone number";
    }
    if (email.length<5) {
        return @"Please correct email number";
    }

    return @"";
}

- (void)requestOTPForUpdateProfile{
    NSString *validFormResult = [self validateFormWithTel:self.telephoneField.text email:self.emailField.text];
    if(![validFormResult isEqualToString:@""]){
        self.warningLabel.text = validFormResult;
        return;
    }
    
    [CMUser requestOTPUpdateProfileBlock:^(BOOL isSuccess, NSString *referenceID, NSString *message, NSError *error) {
        
        if (isSuccess) {
            _referenceID = referenceID;
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Enter OTP code"];
            [dialog setMessage:[NSString stringWithFormat:@"%@ \n Ref: %@",message, _referenceID]];
            [dialog addButtonWithTitle:@"Cancel"];
            [dialog addButtonWithTitle:@"OK"];
            dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
            _alertOTPTextField = [dialog textFieldAtIndex:0];
            _alertOTPTextField.keyboardType = UIKeyboardTypeNumberPad;
            _alertOTPTextField.placeholder = @"Enter OTP";
            
            
            [dialog show];

        }
    }];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0) {
        //Cancel Button
        
    }
    if (buttonIndex == 1){
        //Ok Button
        _otp = _alertOTPTextField.text;
        NSLog(@"OTP:%@, ReferenceID:%@", _otp, _referenceID);
        
        [self confirmUpdateProfileWithOTP: _otp referenceID:_referenceID];
        
    }
}

-(void)confirmUpdateProfileWithOTP:(NSString *)otp referenceID:(NSString *)refID {
    
        if (otp.length==0) {
            self.warningLabel.text = @"Please input OTP";
            return;
        }
    
    NSString *firstnameStr = self.firstnameField.text;
    NSString *lastnameStr = self.lastnameField.text;
    NSString *birthdateStr = self.birthdateField.text;
    NSString *emailStr = self.emailField.text;
    NSString *telStr = self.telephoneField.text;
    NSString *sexStr = _sex;
  
    NSArray *stringArray = [birthdateStr componentsSeparatedByString: @"-"];
    NSString *birthdayStr = [stringArray objectAtIndex:0];
    NSString *birthmonthStr = [stringArray objectAtIndex:1];
    NSString *birthyearStr = [stringArray objectAtIndex:2];
    
    [CMUser confirmUpdateProfileWithOTP:otp referenceID:refID firstname:firstnameStr lastname:lastnameStr birthdate:birthdateStr birthday:birthdayStr birthmonth:birthmonthStr birthyear:birthyearStr sex:sexStr tel:telStr email:emailStr Block:^(BOOL isSuccess, NSString *message, NSError *error) {
        
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
