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
    
//    NSLog(@"thumbs %d", self.recentPhotosList.thumbnailsCache.count);
//    NSLog(@"photo %d", self.recentPhotosList.photosCache.count);
    
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
//    NSArray *thumbCache = [self.recentPhotosList.thumbnailsCache copy];
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
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *thumbData;
        UIImage *thumb;
        NSString *photoID = [photo objectForKey:@"id"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThumbCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        NSString *filePath = [dataPath stringByAppendingPathComponent:photoID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"thumb from cache");
            thumb = [UIImage imageWithContentsOfFile:filePath];
        } else {
            NSLog(@"thumb download");
            thumbData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]];
            if (!thumbData) {
                thumb = cell.imageView.image;
            } else {
                thumb = [UIImage imageWithData:thumbData];
            }
            [[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents:thumbData
                                                  attributes:nil];
            // добавить проверку количества файлов в кэше
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imageView setImage:thumb];
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
            
            NSDictionary *photo = [[self.recentPhotos objectAtIndex:indexPath.row] mutableCopy];
            NSString *photoID = [photo objectForKey:@"id"];
            UIImage *image;
            NSData *imageData;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PhotoCache"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSString *filePath = [dataPath stringByAppendingPathComponent:photoID];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSLog(@"File exist");
                NSLog(@"image from cache");
                image = [UIImage imageWithContentsOfFile:filePath];
            } else {
                NSLog(@"File not found");
                NSLog(@"image download");
                imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:2]];
                image = [UIImage imageWithData:imageData];
                [self.recentPhotosList addPhotoToRecentPhotosList:photo];
                [[NSFileManager defaultManager] createFileAtPath:filePath
                                                        contents:imageData
                                                      attributes:nil];
                // добавить проверку количества файлов в кэше
            }
            

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
