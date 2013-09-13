//
//  FavoriteViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/3/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "FavoriteViewController.h"

#import "AppDelegate.h"
#import "ProgramViewCell.h"
#import "Program.h"
#import "ProgramListViewController.h"
#import "GADBannerView.h"
//#import "GANTracker.h"
#import "Three20/Three20.h"
#import "IIViewDeckController.h"
static NSString *programViewcell = @"ProgramViewCell";

@interface FavoriteViewController ()
{
    GADBannerView *bannerView;
    CGFloat cellHeight;
    BOOL isPad;
}
@end

@implementation FavoriteViewController

@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize viewBanner = _viewBanner;
@synthesize tableView= _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeData
{
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeData];
    
    self.navigationItem.title = @"My Favorites";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconLauncher"] style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tableViewBeginEditMode:)];
    // Setup AdMob
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPad;
        cellHeight = 120.0;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
        cellHeight = 90.0;
    }
    
    bannerView.rootViewController = self;
    
    [self.viewBanner addSubview:bannerView];
    
    [bannerView loadRequest:[GADRequest request]];
    
    // GANTracker
//    NSError *error;
//    
//    if (![[GANTracker sharedTracker] trackPageview:@"/openFavorite"
//                                         withError:&error]) {
//        // Handle error here
//    }
    
    [self.tableView reloadData];
}

- (IBAction)tableViewBeginEditMode:(id)sender
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tableViewEndEditMode:)];
    [self.tableView setEditing:YES animated:YES];
}

- (IBAction)tableViewEndEditMode:(id)sender
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tableViewBeginEditMode:)];
    [self.tableView setEditing:NO animated:YES];
}

- (void)viewDidUnload
{
    [self setViewBanner:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProgramViewCell *cell = (ProgramViewCell *)[tableView dequeueReusableCellWithIdentifier:programViewcell];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]
                                    loadNibNamed:programViewcell owner:nil options:nil];
        for (id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[ProgramViewCell class]])
            {
                cell = (ProgramViewCell *)currentObject;
                break;
            }
        }
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.thumbnail.defaultImage = [UIImage imageNamed:@"Icon"];
        if(isPad)
        {
            [cell.thumbnail setFrame:CGRectMake(3, 5, 150, 110)];
            [cell.title setFrame:CGRectMake(160, 8, cell.title.frame.size.width, cell.title.frame.size.height)];
            [cell.title setFont:[UIFont systemFontOfSize:28]];
            [cell.detail setFrame:CGRectMake(160, 40, cell.detail.frame.size.width, cell.detail.frame.size.height)];
            [cell.detail setFont:[UIFont systemFontOfSize:24]];
        }
    }
    
    // Configure the cell...
    [self configureCell:cell atIindexPath:indexPath];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *toDelete = [self.fetchedResultsController
                                     objectAtIndexPath:indexPath];
        
        Program *program = (Program*)toDelete;
        [self unregisterLikeProgram:program.program_id];
        
        [self.managedObjectContext deleteObject:toDelete];
        [self.managedObjectContext save:nil];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Program *program = (Program*)[self.fetchedResultsController
                                  objectAtIndexPath:indexPath];
    //Initialize the detail view controller and display it.
    
    NSString *nibName = (isPad)?@"ProgramListViewController_iPad":@"ProgramListViewController_iPhone";
    
    ProgramListViewController *programController = [[ProgramListViewController alloc] initWithNibName:nibName bundle:nil];
    programController.program_id = program.program_id;
    programController.program_title = program.program_title;
    programController.program_time = program.program_time;
    programController.program_thumbnail = program.program_thumbnail;
    [self.navigationController pushViewController:programController animated:YES];
}

- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (void)configureCell:(ProgramViewCell *)cell atIindexPath:(NSIndexPath *)indexPath
{
    Program *program = (Program*)[self.fetchedResultsController
                                  objectAtIndexPath:indexPath];
    [cell.title setText:program.program_title];
    [cell.detail setText:program.program_time];
    cell.thumbnail.urlPath = program.program_thumbnail;
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
    
    //    NSFetchedResultsController *aFetchResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"tvthaiCache"] autorelease];
    NSFetchedResultsController *aFetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"tvthaiCache"];
    aFetchResultsController.delegate = self;
    self.fetchedResultsController = aFetchResultsController;
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Cannot fetch objects Error: %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (void)unregisterLikeProgram:(NSString *)program_id
{
//    NSString *uniqueIdentifier = [[UIDevice currentDevice] uniqueIdentifier];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kUnregisterLikeProgram(program_id, uniqueIdentifier)]];
//    [request startAsynchronous];
//    NSLog(@"%@", request.url.absoluteString);
}


@end
