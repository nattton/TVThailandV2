//
//  CMAddCreditViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/7/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMAddCreditViewController.h"
#import "CMUser.h"

@interface CMAddCreditViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberIDLabel;

@end


@implementation CMAddCreditViewController{
    NSString *_username;
    NSString *_memberID;
}


static NSString *cmWebViewSegue = @"CMWebViewSegue";


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
    CMUser *cmUser = [CMUser sharedInstance];
    NSLog(@"%@",cmUser);
    _username = cmUser.userName;
    _memberID = cmUser.memberId;
    NSString *formatMemberID = [self formatMemberID:_memberID];
    
    
    self.usernameLabel.text = _username;
    self.memberIDLabel.text = formatMemberID;
	
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
- (IBAction)tabOnAddTrueMoneyButton:(id)sender {
    [self performSegueWithIdentifier:cmWebViewSegue sender:nil];
}

- (NSString *)formatMemberID:(NSString*)memberID{
    NSMutableString *displayMemberID = [NSMutableString string];
    NSMutableArray *array = [NSMutableArray array];
    NSString *ch = [NSString string];
    int j=0;
    for (int i=0; i< memberID.length;i++) {
        if (i % 4 == 0 && i != 0) {
            ch = [memberID substringWithRange:NSMakeRange(j, 4)];
            [array addObject:[NSString stringWithFormat:@"%@-",ch]];
            NSLog(@"%@",ch);
            j=j+4;
        }
        
    }
    ch = [memberID substringFromIndex:j];
    [array addObject:ch];
    NSLog(@"%@",ch);
    
    for (int i=0; i<=array.count-1;i++){
        [displayMemberID appendString:[NSMutableString stringWithFormat:@"%@",[array objectAtIndex:i]]];
        
    }
    
    return displayMemberID;
}


@end
