//
//  ProgramDetailViewController.m
//  TV_Thailand
//
//  Created by Nattapong Tonprasert on 1/16/12.
//  Copyright (c) 2012 luciferultram@gmail.com. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import "SBJson.h"
#import "NSString+Utils.h"
#import "GANTracker.h"
#import "Three20/Three20.h"
@implementation ProgramDetailViewController

@synthesize titleLabel;
@synthesize detailLabel;
@synthesize thumbnail;
@synthesize program_id = _program_id;
@synthesize program_title = _program_title;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.program_title;
    titleLabel.text = self.program_title;
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:kGetProgramDetail(self.program_id)]];
    request.delegate = self;
    [request startAsynchronous];
    
    // GANTracker
    
    NSError *error;
    
    if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/getProgramDetail/%@",self.program_id ]
                                         withError:&error]) {
        // Handle error here
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDictionary *dict = [[request responseString] JSONValue];
    if (dict)
    {
        thumbnail.urlPath = [NSString stringWithFormat:@"%@",[dict objectForKey:@"thumbnail"]];
        thumbnail.style = [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10.0f] next:[TTContentStyle styleWithNext:nil]]];
        
        NSMutableString *detail = [[NSMutableString alloc] init];
        [detail appendString:[dict objectForKey:@"time"]];
        if (![[dict objectForKey:@"detail"] isEqualToString:@""]) {
            [detail appendString:[NSString stringWithFormat:@"\nรายละเอียด : %@",[dict objectForKey:@"detail"]]];
        }
        [detail appendString:[NSString stringWithFormat:@"\n\nจำนวนครั้งที่ชม : %@",[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[dict objectForKey:@"count"] intValue]]]]];
        //        NSString *programTitle = [dict objectForKey:@"title"];
        [detailLabel setText:detail];
    }
}


- (void)viewDidUnload
{
    [self setDetailLabel:nil];
    [self setTitleLabel:nil];
    [self setThumbnail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)closeTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
