//
//  InfoOfEpisodeViewController.m
//  TVThailandV2
//
//  Created by April Smith on 6/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "InfoOfEpisodeViewController.h"
#import "OTVEpisode.h"

@interface InfoOfEpisodeViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeight;

@end

@implementation InfoOfEpisodeViewController

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
    
    UIFontDescriptor *baseFont =
    [UIFontDescriptor fontDescriptorWithFontAttributes:
     @{UIFontDescriptorFamilyAttribute:@"Helvetica Neue"}];
    UIFontDescriptor *italicBase =
    [baseFont fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *font = [UIFont fontWithDescriptor:italicBase size:24];
    self.detailTextView.font = font;
    
    self.episodeName.text = self.otvEpisode.nameTh;
    self.updateDate.text = self.otvEpisode.date;
    self.detailTextView.text = self.otvEpisode.detail;

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        return ceilf(usedRect.size.height
                     + textView.textContainerInset.top
                     + textView.textContainerInset.bottom);
    }
    
    return 320;
}

@end
