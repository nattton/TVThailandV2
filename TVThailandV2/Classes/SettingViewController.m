//
//  SettingViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/26/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
{
    BOOL _switch1State;
}
@end

@implementation SettingViewController
@synthesize tableView = _tableView;

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

    self.navigationItem.title = @"Setting";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
}

- (IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Video Player";
        case 1:
            return @"Category";
        default:
            return @"Menu";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        
        UISwitch *_switch = [[UISwitch alloc] initWithFrame:CGRectMake(210.0f, 10.0f, 0.0f, 0.0f)];
        [_switch sizeToFit];
        [_switch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
        _switch.tag = indexPath.section + 1;
        [cell setAccessoryView:_switch];
        
//        UISwitch *_switch = [[UISwitch alloc] initWithFrame:CGRectMake(210.0f, 10.0f, 0.0f, 0.0f)];
//        [_switch sizeToFit];
//        [_switch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
//        _switch.tag = indexPath.section + 1;
//        [cell addSubview:_switch];
    }
    
    if(0 == indexPath.section)
    {
        if (0 == indexPath.row) {
            cell.textLabel.text = @"Youtube AutoPlay";
            ((UISwitch *)[cell viewWithTag:1]).on = [[NSUserDefaults standardUserDefaults] boolForKey:kYoutubeAutoPlay];
        }
        else if (1 == indexPath.row) {
            cell.textLabel.text = @"Show Thumbnail";
            ((UISwitch *)[cell viewWithTag:2]).on = _switch1State;
        }

    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) switchDidChange:(UISwitch*)sender
{
    if(1 == sender.tag) {
        _switch1State = sender.on;
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kYoutubeAutoPlay];
    }
}

@end
