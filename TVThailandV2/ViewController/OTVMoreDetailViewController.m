//
//  OTVMoreDetailViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVMoreDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "XLMediaZoom.h"
#import "OTVShow.h"

@interface OTVMoreDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@end

@implementation OTVMoreDetailViewController {
     XLMediaZoom *_imageZoom;
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
    
    self.titleLabel.text = self.otvShow.title;
    self.detailTextView.text = self.otvShow.detail;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:self.otvShow.thumbnail] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.thumbnailImageView.layer.cornerRadius = 10.0;
    self.thumbnailImageView.clipsToBounds = YES;
    
    _imageZoom = [[XLMediaZoom alloc] initWithAnimationTime:@(0.5) image:self.thumbnailImageView blurEffect:YES];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.thumbnailImageView addGestureRecognizer:singleTap];
    [self.thumbnailImageView setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    [self.view addSubview:_imageZoom];
    [_imageZoom show];
    if (self.otvShow.thumbnail != nil && self.otvShow.thumbnail.length > 0) {
        [_imageZoom.imageView setImageWithURL:[NSURL URLWithString:self.otvShow.thumbnail]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [_imageZoom.imageView setImage:image];
        }];
    }
    
}

- (IBAction)doneButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
