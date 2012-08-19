//
//  VacationsTableViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/9/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "VacationsTableViewController.h"
#import "FlickrFetcher.h"
#import "Place.h"

@interface VacationsTableViewController ()

@end

@implementation VacationsTableViewController

@synthesize vacationDatabase = _vacationDatabase;

- (void)setVacationDatabase:(UIManagedDocument *)vacationDatabase
{
    if (_vacationDatabase != vacationDatabase) {
        _vacationDatabase = vacationDatabase;
        [self useDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.vacationDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Vacation Database"];
        self.vacationDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.vacationDatabase.fileURL path]]) {
        [self.vacationDatabase saveToURL:self.vacationDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            [self setupFetchedResultsController];
            [self fetchFlickrDataIntoDocument:self.vacationDatabase];
            NSLog(@"!fileExistsAtPath");
        }];
    } else if (self.vacationDatabase.documentState == UIDocumentStateClosed) {
        [self.vacationDatabase openWithCompletionHandler:^(BOOL success) {
            [self fetchFlickrDataIntoDocument:self.vacationDatabase];
//            [self setupFetchedResultsController];
            NSLog(@"UIDocumentStateClosed");
        }];
    } else if (self.vacationDatabase.documentState == UIDocumentStateNormal) {
//        [self setupFetchedResultsController];
        NSLog(@"UIDocumentStateNormal");
    }
}

- (void)fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        NSLog(@"photos %@", photos);
        [document.managedObjectContext performBlock:^{
            for (NSDictionary *flickrInfo in photos) {
//                [Place photoWithFlickrInfo:flickrInfo inMabagedObjectContex:document.managedObjectContext];
            }
        }];
    });
    dispatch_release(fetchQ);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}


@end
