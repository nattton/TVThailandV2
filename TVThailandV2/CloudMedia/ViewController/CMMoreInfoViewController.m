//
//  CMMoreInfoViewController.m
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMMoreInfoViewController.h"
#import "CMMovie.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+AFNetworking.h"


@interface CMMoreInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbNailImageView;


@end

@implementation CMMoreInfoViewController

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

//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadWithURL:[NSURL URLWithString:self.cmMoive.imageSmall] options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//        [self.thumbNailImageView setImage:[self blur:image]];
//
//    }];
    
    [self.thumbNailImageView setImageWithURL:[NSURL URLWithString:self.cmMoive.imageSmall]];

    
    CGRect labelFrameOfTitle = CGRectMake(44,245,232,68);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:labelFrameOfTitle];
    
    [titleLabel setText:self.cmMoive.thaiName];
    [titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [titleLabel setNumberOfLines:0];
    [titleLabel sizeToFit];
    
    

    CGRect labelFrameOfDes = CGRectMake(44,321,232,225);
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:labelFrameOfDes];
    [descriptionLabel setTextColor:[UIColor grayColor]];
    
    [descriptionLabel setText:self.cmMoive.descriptionOfMovie];
    [descriptionLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel sizeToFit];

    
    [self.view addSubview:titleLabel];
    [self.view addSubview:descriptionLabel];
   
//    self.descriptionLabel.textAlignment = UIControlContentVerticalAlignmentTop;
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

- (UIImage*) blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

@end
