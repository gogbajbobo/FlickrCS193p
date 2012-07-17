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

@interface RecentPhotosTableViewController ()
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *selectedPhotoTitle;
@property (nonatomic) BOOL rowDidSelected;
@property (nonatomic) BOOL refreshRecentPhotoList;
@end

@implementation RecentPhotosTableViewController
@synthesize recentPhotos = _recentPhotos;
@synthesize photosFromPlace = _photosFromPlace;
@synthesize image = _image;
@synthesize selectedPhotoTitle = _selectedPhotoTitle;
@synthesize rowDidSelected = _rowDidSelected;
@synthesize refreshRecentPhotoList = _refreshRecentPhotoList;


#define RECENT_PHOTOS_KEY @"Flickr.recentPhotos"
#define MAX_NUMBER_OF_PHOTOS 50
#define MAX_NUMBER_OF_THUMBS 200
#define MAX_SIZE_OF_CACHE_IN_MB 10

- (NSMutableArray *)recentPhotos
{
    if (!self.photosFromPlace && self.refreshRecentPhotoList) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
        if (!_recentPhotos) _recentPhotos = [NSMutableArray array];
        self.refreshRecentPhotoList = NO;
    }
    return _recentPhotos;
}

- (void)addPhotoToRecentPhotosList:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotosList = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!recentPhotosList) recentPhotosList = [NSMutableArray array];
    NSString *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < recentPhotosList.count; i++) {
        NSString *photoID = [[recentPhotosList objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [recentPhotosList insertObject:photo atIndex:0];
    if (recentPhotosList.count > MAX_NUMBER_OF_PHOTOS) {
        NSRange range;
        range.location = MAX_NUMBER_OF_PHOTOS - 1;
        range.length = recentPhotosList.count - MAX_NUMBER_OF_PHOTOS;
        [recentPhotosList removeObjectsInRange:range];
    }
    [defaults setObject:recentPhotosList forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
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
    if (!self.photosFromPlace) {
        self.refreshRecentPhotoList = YES;
        [self.tableView reloadData];
    }
    // This should be placed somethere else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThumbCache"];
    [self checkNumberOfFilesInCache:dataPath];
    //
}

- (void)viewDidLoad
{
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
            thumb = [UIImage imageWithContentsOfFile:filePath];
        } else {
            thumbData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]];
            if (!thumbData) {
                thumb = cell.imageView.image;
            } else {
                thumb = [UIImage imageWithData:thumbData];
            }
            [[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents:thumbData
                                                  attributes:nil];
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
                image = [UIImage imageWithContentsOfFile:filePath];
            } else {
                imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:2]];
                image = [UIImage imageWithData:imageData];
                [self addPhotoToRecentPhotosList:photo];
                [[NSFileManager defaultManager] createFileAtPath:filePath
                                                        contents:imageData
                                                      attributes:nil];
                [self checkCacheSize:dataPath];
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

- (void)checkCacheSize:(NSString *)cachePath {
    if ([self folderSize:cachePath] > MAX_SIZE_OF_CACHE_IN_MB * 1024 * 1024) {
//        NSLog(@"Need to clean");
        NSArray *filesPathArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
        NSEnumerator *filesEnumerator = [filesPathArray objectEnumerator];
        NSString *fileName;
        NSMutableArray *filesAttributeArray = [NSMutableArray array];

        while (fileName = [filesEnumerator nextObject]) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSMutableDictionary *fileDic = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] mutableCopy];
            [fileDic setValue:fileName forKey:@"FileName"];
            [filesAttributeArray addObject:fileDic];
        }

        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"NSFileModificationDate" ascending:NO]];
        filesAttributeArray = [[filesAttributeArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

        NSString *fileNameToDelete = [[filesAttributeArray lastObject] objectForKey:@"FileName"];
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileNameToDelete];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

        [self checkCacheSize:cachePath];
    } else {
//        NSLog(@"No need to clean");
    }
}

- (int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

- (void)checkNumberOfFilesInCache:(NSString *)cachePath {
    NSArray *filesPathArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
    NSLog(@"Thumb cache %d", filesPathArray.count);
    if (filesPathArray.count > MAX_NUMBER_OF_THUMBS) {
        NSLog(@"Need to remove files");
        NSEnumerator *filesEnumerator = [filesPathArray objectEnumerator];
        NSString *fileName;
        NSMutableArray *filesAttributeArray = [NSMutableArray array];

        while (fileName = [filesEnumerator nextObject]) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSMutableDictionary *fileDic = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] mutableCopy];
            [fileDic setValue:fileName forKey:@"FileName"];
            [filesAttributeArray addObject:fileDic];
        }
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"NSFileModificationDate" ascending:NO]];
        filesAttributeArray = [[filesAttributeArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        NSString *fileNameToDelete = [[filesAttributeArray lastObject] objectForKey:@"FileName"];
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileNameToDelete];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [self checkNumberOfFilesInCache:cachePath];
        
    } else {
        NSLog(@"No need to remove files");
    }

}


@end
