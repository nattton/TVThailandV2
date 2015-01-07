//
//  FavoritesViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "FavoriteViewController.h"
#import "AppDelegate.h"
#import "ShowTableViewCell.h"
#import "Program.h"
#import "Show.h"
#import "Episode.h"

#import "EpisodePartViewController.h"
#import "OTVEpisodePartViewController.h"

#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface FavoriteViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (unsafe_unretained, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;

@end

@implementation FavoriteViewController

static NSString *cellIdentifier = @"ShowCellIdentifier";
//static NSString *showEpisodeSegue = @"ShowEpisodeSegue";
static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";
static NSString *OTVEPAndPartIdentifier = @"OTVEPAndPartIdentifier";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        
        Show *show = (Show *)sender;
        EpisodePartViewController *episodeAndPartListViewController = segue.destinationViewController;
        episodeAndPartListViewController.show = show;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Favorite"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:show.title
                                                          forKey:[GAIFields customDimensionForIndex:2]] build]];
    }
    else if ([segue.identifier isEqualToString:OTVEPAndPartIdentifier])
    {
        Show *show = (Show *)sender;
        
        OTVEpisodePartViewController *otvEpAndPartViewController = segue.destinationViewController;
        otvEpAndPartViewController.navigationItem.title = show.title;
        
        otvEpAndPartViewController.show = show;
    }
    
    
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
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
	
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Favorite"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.numberOfObjects;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     Program *program = (Program*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    [Episode retrieveDataWithId:program.program_id
                             Start:0
                             Block:^(Show *show, NSArray *tempEpisodes, NSError *error)
    {
        [SVProgressHUD dismiss];
         if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) && show.isOTV)
             [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
         else
             [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    }];
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Program *program = (Program*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithProgram:program];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *toDelete = [self.fetchedResultsController
                                     objectAtIndexPath:indexPath];
        
        [self.managedObjectContext deleteObject:toDelete];
        [self.managedObjectContext save:nil];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
//    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeInsert) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeInsert) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - CoreData
- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"program_title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchResultsController.delegate = self;
    self.fetchedResultsController = aFetchResultsController;
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error])
    {
        DLog(@"Cannot fetch objects Error: %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

#pragma mark - IBAction

- (IBAction)editFavoriteTapped:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.editBarButton.title = @"Edit";
    } else {
        [self.tableView setEditing:YES animated:YES];
        self.editBarButton.title = @"Done";
    }
}


@end
