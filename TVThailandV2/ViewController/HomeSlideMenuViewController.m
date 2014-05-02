//
//  HomeSlideMenuViewController.m
//  TVThailandV2
//
//  Created by April Smith on 4/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "HomeSlideMenuViewController.h"
#import "HomeContentViewController.h"
#import "ShowCategoryList.h"
#import "ShowCategoryTableViewCell.h"
#import "SVProgressHUD.h"

@interface HomeSlideMenuViewController () <SASlideMenuDataSource, SASlideMenuDelegate, UITableViewDataSource, UITableViewDelegate>



@end



@implementation HomeSlideMenuViewController {

 UIRefreshControl *_refreshControl;
 ShowCategoryList *_categoryList;
    
}

static NSString *cateCellIdentifier = @"cateCellIdentifier";

-(void)tap:(id)sender{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _categoryList = [[ShowCategoryList alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self reload];

}

- (void)reload
{
    [_categoryList loadData:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

#pragma mark -
#pragma mark SASlideMenuDataSource

-(void) prepareForSwitchToContentViewController:(UINavigationController *)content{
    UIViewController* controller = [content.viewControllers firstObject];
//    if ([controller isKindOfClass:[ColoredViewController class]]) {
//        ColoredViewController* coloredViewController = (ColoredViewController*) controller;
//        [coloredViewController setBackgroundHue:selectedHue brightness:selectedBrightness];
//    }else if ([controller isKindOfClass:[GreenViewController class]]) {
//       
//    }
    HomeContentViewController* homeContentViewController = (HomeContentViewController*) controller;
    homeContentViewController.menuController = self;
}

// It configure the menu button. The beahviour of the button should not be modified
-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 25, 40);
    [menuButton setImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
}


// It configure the right menu button. The beahviour of the button should not be modified
//-(void) configureRightMenuButton:(UIButton *)menuButton{
//    menuButton.frame = CGRectMake(0, 0, 40, 29);
//    [menuButton setImage:[UIImage imageNamed:@"menuiconright"] forState:UIControlStateNormal];
//}

// This is the segue you want visibile when the controller is loaded the first time
-(NSIndexPath*) selectedIndexPath{
//    if (_categoryList && [_categoryList count] > 0) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
//    }
//    return nil;
//    return nil;
}

// It maps each indexPath to the segueId to be used. The segue is performed only the first time the controller needs to loaded, subsequent switch to the content controller will use the already loaded controller

-(NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{
//    NSString* result;
//    switch (indexPath.section) {
//        case 0:
//            result = @"red";
//            break;
//        case 1:
//            result = @"green";
//            break;
//        default:
//            result = @"blue";
//            break;
//    }
    return @"homeContentSegue";
}

-(Boolean) disableContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return @"Red";
//    }else if (section == 1){
//        return @"Green";
//    }else {
//        return @"Blue";
//    }
    return nil;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_categoryList && [_categoryList count] > 0) {
        return [_categoryList count];
    }
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat brightness = 1-((double) indexPath.row)/5;
//    NSInteger section = indexPath.section;
//    CGFloat hue=0;
//    if (section == 0) {
//        hue = 0.0;
//    }else if (section==1){
//        hue = 0.33;
//    }else if (section==2){
//        hue = 0.66;
//    }
//    cell.backgroundColor = [UIColor colorWithHue:hue saturation:1.0 brightness:brightness alpha:1.0];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cateCellIdentifier"];
    ShowCategoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cateCellIdentifier"];
    
        [cell configureWithGenre:_categoryList[indexPath.row]];
    
    return cell;
}

-(CGFloat) leftMenuVisibleWidth{
    return 260;
}



////restricts pan gesture interation to 50px on the left and right of the view.
//-(Boolean) shouldRespondToGesture:(UIGestureRecognizer*) gesture forIndexPath:(NSIndexPath*)indexPath {
//    CGPoint touchPosition = [gesture locationInView:self.view];
//    return (touchPosition.x < 50.0 || touchPosition.x > self.view.bounds.size.width - 50.0f);
//}

#pragma mark -
#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat brightness = 1-((double) indexPath.row)/5;
//    NSInteger section = indexPath.section;
//    CGFloat hue=0;
//    if (section == 0) {
//        hue = 0.0;
//    }else if (section==1){
//        hue = 0.33;
//    }else if (section==2){
//        hue = 0.66;
//    }
//    self.selectedHue = hue;
//    self.selectedBrightness = brightness;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}
#pragma mark -
#pragma mark SASlideMenuDelegate

-(void) slideMenuWillSlideIn:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideIn");
}
-(void) slideMenuDidSlideIn:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideIn");
}
-(void) slideMenuWillSlideToSide:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideToSide");
}
-(void) slideMenuDidSlideToSide:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideToSide");
}
-(void) slideMenuWillSlideOut:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideOut");
}
-(void) slideMenuDidSlideOut:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideOut");
}
-(void) slideMenuWillSlideToLeft:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideToLeft");
}
-(void) slideMenuDidSlideToLeft:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideToLeft");
}



@end
