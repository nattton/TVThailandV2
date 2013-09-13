//
//  GenreListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "GenreListViewController.h"
#import "GenreTableViewCell.h"
#import "Genre.h"
#import "GenreList.h"

#import "ShowListViewController.h"

@interface GenreListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GenreListViewController {
    
@private
    GenreList *_genreList;
}

static NSString *cellIdentifier = @"GenreCellIdentifier";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIViewController

- (void) loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    _genreList = [[GenreList alloc] initWithSamples];
    _genreList = [[GenreList alloc] init];
    [_genreList loadData:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _genreList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GenreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.section == 0) {
        [cell configureAllGenre];
    }
    else {
        [cell configureWithGenre:_genreList[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (indexPath.section == 0) {
            self.showListViewController.navigationItem.title = @"TV Thailand";
            [self.showListViewController reloadWithMode:kWhatsNew Id:nil];
            
        }
        else {
            Genre *selectedGenre = _genreList[indexPath.row];
            self.showListViewController.navigationItem.title = selectedGenre.title;
            [self.showListViewController reloadWithMode:kGenre Id:selectedGenre.Id];
            
        }
    }];
    
    if (indexPath.section == 0) {
        self.showListViewController.navigationItem.title = @"TV Thailand";
        [self.showListViewController reloadWithMode:kWhatsNew Id:nil];
        
    }
    else {
        Genre *selectedGenre = _genreList[indexPath.row];
        self.showListViewController.navigationItem.title = selectedGenre.title;
        [self.showListViewController reloadWithMode:kGenre Id:selectedGenre.Id];
        
    }
}

@end
