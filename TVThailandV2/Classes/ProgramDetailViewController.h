//
//  ProgramDetailViewController.h
//  TV_Thailand
//
//  Created by Nattapong Tonprasert on 1/16/12.
//  Copyright (c) 2012 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
@class TTImageView;
@interface ProgramDetailViewController : UIViewController <ASIHTTPRequestDelegate>
{
    TTImageView *thumbnail;
}
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *detailLabel;
@property (strong, nonatomic) IBOutlet TTImageView *thumbnail;
@property (strong, nonatomic) NSString *program_id;
@property (strong, nonatomic) NSString *program_title;

@end
