//
//  DetailViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "DetailViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "XLMediaZoom.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "Show.h"
#import "OTVShow.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeight;

@end

@implementation DetailViewController {
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
    [self initializeUI];
    
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Detail"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)initializeUI {
    [self.detailTextView setEditable:YES];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.detailTextView setFont:[UIFont fontWithName:@"Helvetica" size:24]];
    } else {
        [self.detailTextView setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    }
    
    [self.detailTextView setEditable:NO];
    if (self.show) {
        self.titleLabel.text = self.show.title;
        self.detailTextView.text = self.show.detail;
        [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    else if (self.otvShow)
    {
        self.titleLabel.text = self.otvShow.title;
        self.detailTextView.text = self.otvShow.detail;
        [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.otvShow.thumbnail] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    }
    
    self.thumbnailImageView.layer.cornerRadius = 10.0;
    self.thumbnailImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.thumbnailImageView addGestureRecognizer:singleTap];
    [self.thumbnailImageView setUserInteractionEnabled:YES];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.detailTextViewHeight.constant = [self textViewHeight:self.detailTextView];
}

- (CGFloat)textViewHeight:(UITextView *)textView
{
    if ([textView respondsToSelector:@selector(layoutManager)])
    {
        [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
        CGRect usedRect = [textView.layoutManager
                           usedRectForTextContainer:textView.textContainer];
        return ceilf(usedRect.size.height) + 10;
    }

    return 400;
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    _imageZoom = [[XLMediaZoom alloc] initWithAnimationTime:@(0.5) image:self.thumbnailImageView blurEffect:YES];
    [self.view addSubview:_imageZoom];
    [_imageZoom show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
