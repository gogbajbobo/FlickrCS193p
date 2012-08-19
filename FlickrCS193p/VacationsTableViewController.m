//
//  VacationsTableViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/9/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "VacationsTableViewController.h"

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
//            [self fetchFlickrDataIntoDocument:self.photoDatabase];
            NSLog(@"1");
        }];
    } else if (self.vacationDatabase.documentState == UIDocumentStateClosed) {
        [self.vacationDatabase openWithCompletionHandler:^(BOOL success) {
//            [self setupFetchedResultsController];
            NSLog(@"2");
        }];
    } else if (self.vacationDatabase.documentState == UIDocumentStateNormal) {
//        [self setupFetchedResultsController];
        NSLog(@"3");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}


@end
