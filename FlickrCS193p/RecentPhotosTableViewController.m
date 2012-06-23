//
//  RecentPhotosTableViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/16/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
// 


#import "RecentPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "RecentPhotos.h"

@interface RecentPhotosTableViewController ()
@property (nonatomic, strong) RecentPhotos *recentPhotosList;
@property (nonatomic) BOOL recentList;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *selectedPhotoTitle;
@property (nonatomic) BOOL rowDidSelected;
@end

@implementation RecentPhotosTableViewController
@synthesize recentPhotos = _recentPhotos;
@synthesize recentPhotosList = _recentPhotosList;
@synthesize recentList = _recentList;
@synthesize image = _image;
@synthesize selectedPhotoTitle = _selectedPhotoTitle;
@synthesize rowDidSelected = _rowDidSelected;


- (RecentPhotos *)recentPhotosList
{
    if (!_recentPhotosList) _recentPhotosList = [[RecentPhotos alloc] init];
    return _recentPhotosList;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.recentPhotos || self.recentList) {
        self.recentPhotos = self.recentPhotosList.recentPhotos;
        [self.tableView reloadData];
        self.recentList = YES;
    }
}

- (void)viewDidLoad
{
    self.recentList = NO;
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"resentPhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *photo = [self.recentPhotos objectAtIndex:indexPath.row];
    NSString *recentPhotoTitle = [photo valueForKey:@"title"];
    NSString *recentPhotoDescription = [[photo valueForKey:@"description"] valueForKey:@"_content"];

    if ([recentPhotoTitle isEqualToString:@""]) {
        if ([recentPhotoDescription isEqualToString:@""]) {
            recentPhotoTitle = @"Unknown";
        } else {
            recentPhotoTitle = recentPhotoDescription;
            recentPhotoDescription = @"";
        }
    }
    
    cell.textLabel.text = recentPhotoTitle;
    cell.detailTextLabel.text = recentPhotoDescription;
//    UIImage *cellImage = [UIImage imageWithData:nil];
//    [cell.imageView setImage:cellImage];

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imageView setImage:[UIImage imageWithData:data]];
        });
    });
    dispatch_release(downloadQueue);
    
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

- (PhotoViewController *)splitViewPhotoViewController
{
    id phvc = [self.splitViewController.viewControllers lastObject];
    if (![phvc isKindOfClass:[PhotoViewController class]]) {
        phvc = nil;
    }
    return phvc;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.rowDidSelected) {
        self.rowDidSelected = YES;
        self.selectedPhotoTitle = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:[self.recentPhotos objectAtIndex:indexPath.row] format:2]]];
            [self.recentPhotosList addPhotoToRecentPhotosList:[self.recentPhotos objectAtIndex:indexPath.row]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                [spinner stopAnimating];
                if ([self splitViewPhotoViewController]) {
                    [self splitViewPhotoViewController].title = self.selectedPhotoTitle;
                    [self splitViewPhotoViewController].photo = image;
                } else {
                    [self performSegueWithIdentifier:@"showPhoto" sender:self];
                }
                self.rowDidSelected = NO;
            });
        });
        dispatch_release(downloadQueue);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        [segue.destinationViewController setTitle:self.selectedPhotoTitle];
        [segue.destinationViewController setPhoto:self.image];
    }
}

@end
