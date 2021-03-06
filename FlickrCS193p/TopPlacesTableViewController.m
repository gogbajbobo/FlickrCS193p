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
#import "MapViewController.h"
#import "FlickrAnnotation.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic, strong) NSArray *recentPhotosFromPlace;
@property (nonatomic, strong) NSArray *topPlacesCountries;
@property (nonatomic, strong) NSDictionary *topPlacesByCountry;
@property (nonatomic, strong) NSString *selectedPlace;
@property (nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (nonatomic) IBOutlet UIBarButtonItem *mapButton;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;
@synthesize recentPhotosFromPlace = _recentPhotosFromPlace;
@synthesize topPlacesCountries = _topPlacesCountries;
@synthesize topPlacesByCountry = _topPlacesByCountry;
@synthesize selectedPlace = _selectedPlace;
@synthesize reloadButton = _reloadButton;
@synthesize mapButton = _mapButton;

- (void)loadTopPlacesList {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem *reloadButton = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:FLICKR_PLACE_URL ascending:YES]];
        NSArray *topPlaces = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortDescriptors];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.topPlaces = topPlaces;
//            NSLog(@"topPlaces %@", topPlaces);
            NSMutableArray *topPlacesCountries = [NSMutableArray array];
            for (int i = 0; i < self.topPlaces.count; i++) {
                NSArray *topPlacesTitles = [[[self.topPlaces objectAtIndex:i] valueForKey:FLICKR_PLACE_URL] componentsSeparatedByString:@"/"];
                if (![topPlacesCountries containsObject:[topPlacesTitles objectAtIndex:1]]) [topPlacesCountries addObject:[topPlacesTitles objectAtIndex:1]];
            }
            self.topPlacesCountries = topPlacesCountries;
            
            NSMutableDictionary *topPlacesByCountry = [NSMutableDictionary dictionary];
            for (int i = 0; i < _topPlacesCountries.count; i++) {
                NSString *country = [_topPlacesCountries objectAtIndex:i];
                NSMutableArray *temp = [NSMutableArray array];
                for (int j = 0; j < self.topPlaces.count; j++) {
                    NSString *topPlacesTitle = [[[[self.topPlaces objectAtIndex:j] valueForKey:FLICKR_PLACE_URL] componentsSeparatedByString:@"/"] objectAtIndex:1];
                    if ([topPlacesTitle isEqualToString:country]) [temp addObject:[self.topPlaces objectAtIndex:j]];
                }
                [topPlacesByCountry setObject:temp forKey:country];
            }
            self.topPlacesByCountry = topPlacesByCountry;

            self.navigationItem.leftBarButtonItem = reloadButton;
            [self.tableView reloadData];
        });
    });
    dispatch_release(downloadQueue);
}

- (IBAction)reloadTopPlaces:(id)sender {
    [self loadTopPlacesList];
}

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        [self updateMapViewAnnotations]; 
//        [self updateSplitViewDetail];
//        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (void)updateMapViewAnnotations {

}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
    for (NSDictionary *place in self.topPlaces) {
        [annotations addObject:[FlickrAnnotation createAnnotationFor:place objectType:@"place"]];
    }
    return annotations;
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
    [self loadTopPlacesList];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.topPlacesCountries count];
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return self.topPlacesCountries;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.topPlacesCountries objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.topPlacesByCountry objectForKey:[self.topPlacesCountries objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"topPlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *topPlacesTitles = [[[[self.topPlacesByCountry objectForKey:[self.topPlacesCountries objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@","];
    NSString *cellTitle = [topPlacesTitles objectAtIndex:0];
    
    NSMutableString *cellSubtitle;
    
    if (topPlacesTitles.count == 3) {
        cellSubtitle = [NSString stringWithFormat:@"%@ / %@", [topPlacesTitles objectAtIndex:1], [topPlacesTitles objectAtIndex:2]];
    } else {
        cellSubtitle = [topPlacesTitles objectAtIndex:1];
    }
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = cellSubtitle;
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPlace = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem *reloadButton = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *recentPhotosFromPlace = [FlickrFetcher photosInPlace:[[self.topPlacesByCountry objectForKey:[self.topPlacesCountries objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recentPhotosFromPlace = recentPhotosFromPlace;
            [spinner stopAnimating];
            self.navigationItem.leftBarButtonItem = reloadButton;
            [self performSegueWithIdentifier:@"showRecentPhotos" sender:self];
        });
    });
    dispatch_release(downloadQueue);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRecentPhotos"]) {
        [segue.destinationViewController setRecentPhotos:[self.recentPhotosFromPlace mutableCopy]];
        [segue.destinationViewController setPhotosFromPlace:YES];
        [segue.destinationViewController setTitle:self.selectedPlace];
    }
    if ([segue.identifier isEqualToString:@"showMapView"]) {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

@end
