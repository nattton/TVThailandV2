//
//  CMForgotPWViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/4/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMForgotPWViewController.h"
#import "CMApiClient.h"
#import "AFJSONRequestOperation.h"
#import "CMUser.h"

@interface CMForgotPWViewController ()<UIAlertViewDelegate>{
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *telephoneField;


@end

@implementation CMForgotPWViewController

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
- (IBAction)tabOnSubmit:(id)sender {
    NSString *email = self.emailField.text;
    NSString *tel = self.telephoneField.text;
    [self forgotPasswordWithEmail:email telephone:tel];
    
}

- (void)forgotPasswordWithEmail:(NSString *)email telephone:(NSString *)tel{
    //Validate Form
    NSString *validFormResult = [self validateFormWithEmail:email tel:tel];
    if (![validFormResult isEqualToString:@""]) {
        self.warningLabel.text = validFormResult;
        return;
    }
    
    [CMUser forgotPasswordWithEmail:email tel:tel Block:^(BOOL isSuccess, NSString *message, NSError *error) {
        if (isSuccess) {
           
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Alert"];
            [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
            [dialog addButtonWithTitle:@"OK"];
            
            [dialog show];
        }else{
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Alert"];
            [dialog setMessage:[NSString stringWithFormat:@"%@",message]];
            [dialog addButtonWithTitle:@"OK"];
            
            [dialog show];
        }
    }];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //u need to change 0 to other value(,1,2,3) if u have more buttons.then u can check which button was pressed.
    
    if (buttonIndex == 0) {
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }

}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (NSString *)validateFormWithEmail:(NSString *)email tel:(NSString *)tel{
    if (email.length<5) {
        return @"*Email is too short. Please enter atleast 6 characters";
    }
    if (![self validateEmailWithString:email]) {
        return @"*Email is not a valid type";
    }
    if (tel.length<9) {
        return @"*Telephone number is too short. Please enter atleast 10 characters";
    }
    
    return @"";
}



@end
