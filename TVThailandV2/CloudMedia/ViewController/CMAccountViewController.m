//
//  CMAccountViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/4/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMAccountViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMUser.h"
#import "CMCategoryViewController.h"
#import "CMProfileViewController.h"
#import "CMApiClient.h"

@interface CMAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation CMAccountViewController

static NSString *CMRegistrationSegue = @"CMRegistrationSegue";
static NSString *CMForgotPasswordSegue = @"CMForgotPasswordSegue";
static NSString *CMLoginToProfileSegue = @"CMLoginToProfileSegue";

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
- (IBAction)tabOnLoginButton:(id)sender {
    if ([self.usernameField.text isEqualToString:@""]) {
        return;
    }
    if ([self.passwordField.text isEqualToString:@""]) {
        return;
    }
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    NSLog(@"username:%@,password:%@",username,password);
    
    
    [CMUser loginWithUsername:username password:password Block:^(BOOL isSuccess, NSString *message, NSError *error) {
        
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


- (IBAction)tabOnForgotPasswordButton:(id)sender {
    [self performSegueWithIdentifier:CMForgotPasswordSegue sender:nil];

}
- (IBAction)tabOnRegisterButton:(id)sender {
    [self performSegueWithIdentifier:CMRegistrationSegue sender:nil];
}

@end
