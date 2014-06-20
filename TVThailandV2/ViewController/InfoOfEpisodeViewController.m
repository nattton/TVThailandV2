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
    
    self.episodeName.text = self.otvEpisode.nameTh;
    self.updateDate.text = self.otvEpisode.date;
    self.infoOfEpisode.text = self.otvEpisode.detail;

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

@end
