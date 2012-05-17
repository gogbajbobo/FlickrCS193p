//
//  TopPlacesTableViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/15/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotosTableViewController.h"
#import "TopPlacesCell.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic) BOOL refreshTopPlaces;
@property (nonatomic, strong) NSArray *recentPhotosFromPlace;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;
@synthesize refreshTopPlaces = _refreshTopPlaces;
@synthesize recentPhotosFromPlace = _recentPhotosFromPlace;

- (NSArray *)topPlaces
{
    if (!_topPlaces || self.refreshTopPlaces) {
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"_content" ascending:YES]];
        _topPlaces = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortDescriptors];
        self.refreshTopPlaces = NO;
    }
//    NSLog(@"_topPlaces %@", _topPlaces);
    return _topPlaces;
}

- (NSArray *)recentPhotos:(int)rowOfPlace
{
    return [FlickrFetcher photosInPlace:[self.topPlaces objectAtIndex:rowOfPlace]  maxResults:50];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.refreshTopPlaces = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
    
    return [self.topPlaces count];

}

- (TopPlacesCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"topPlaceCell";
    TopPlacesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[TopPlacesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *topPlacesTitles = [[[self.topPlaces objectAtIndex:indexPath.row] valueForKey:@"_content"] componentsSeparatedByString:@","];
    NSString *cellTitle = [topPlacesTitles objectAtIndex:0];
    
    NSMutableString *cellSubtitle;
    
    if (topPlacesTitles.count == 3) {
        cellSubtitle = [NSString stringWithFormat:@"%@ / %@", [topPlacesTitles objectAtIndex:1], [topPlacesTitles objectAtIndex:2]];
    } else {
        cellSubtitle = [topPlacesTitles objectAtIndex:1];
    }
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = cellSubtitle;
    cell.row = indexPath.row;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    // Navigation logic may go here. Create and push another view controller.
//     RecentPhotosTableViewController *detailViewController = [[RecentPhotosTableViewController alloc] initWithNibName:nil bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRecentPhotos"]) {
        if ([sender isKindOfClass:[TopPlacesCell class]]) {
            TopPlacesCell *cell = sender;
            self.recentPhotosFromPlace = [FlickrFetcher photosInPlace:[self.topPlaces objectAtIndex:cell.row]  maxResults:50];
        }
        NSLog(@"recentPhotos %@", self.recentPhotosFromPlace);
        [segue.destinationViewController setRecentPhotos:self.recentPhotosFromPlace];
    }
}

@end
