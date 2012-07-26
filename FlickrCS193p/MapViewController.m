//
//  MapViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/22/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "FlickrAnnotation.h"
#import "FlickrFetcher.h"
#import "FlickrCache.h"
#import "PhotoViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSwitch;
@property (strong, nonatomic) NSDictionary *selectedObject;
@property (strong, nonatomic) NSString *nextTitle;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CLLocationCoordinate2D center;
@property (nonatomic) MKCoordinateSpan span;
@property (nonatomic) BOOL checkingCache;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize mapSwitch = _mapSwitch;
@synthesize annotations = _annotations;
@synthesize selectedObject = _selectedObject;
@synthesize nextTitle = _nextTitle;
@synthesize image = _image;
@synthesize center = _center;
@synthesize span = _span;
@synthesize checkingCache = _checkingCache;
//@synthesize delegate = _delegate;

#define RECENT_PHOTOS_KEY @"Flickr.recentPhotos"
#define MAX_NUMBER_OF_PHOTOS 5


- (IBAction)mapSwitchPressed:(id)sender {
    UISegmentedControl *mapSwitch;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        mapSwitch = sender;
    }
//    NSLog(@"MapSwitchValue %d", mapSwitch.selectedSegmentIndex);
    if (mapSwitch.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    } else if (mapSwitch.selectedSegmentIndex == 1) {
        self.mapView.mapType = MKMapTypeSatellite;        
    } else if (mapSwitch.selectedSegmentIndex == 2) {
        self.mapView.mapType = MKMapTypeHybrid;
    }
}

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
    self.mapView.region = MKCoordinateRegionMake(self.center, self.span);
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    FlickrAnnotation *firstAnnotation = [annotations objectAtIndex:0];
    double maxLon = firstAnnotation.coordinate.longitude;
    double minLon = firstAnnotation.coordinate.longitude;
    double maxLat = firstAnnotation.coordinate.latitude;
    double minLat = firstAnnotation.coordinate.latitude;
    for (FlickrAnnotation *annotation in annotations) {
        if (annotation.coordinate.longitude > maxLon) maxLon = annotation.coordinate.longitude;
        if (annotation.coordinate.longitude < minLon) minLon = annotation.coordinate.longitude;
        if (annotation.coordinate.latitude > maxLat) maxLat = annotation.coordinate.latitude;
        if (annotation.coordinate.latitude < minLat) minLat = annotation.coordinate.latitude;
//        NSLog(@"maxLon %f minLon %f maxLat %f minLat %f", maxLon, minLon, maxLat, minLat);
    }
//    NSLog(@"maxLon %f minLon %f maxLat %f minLat %f", maxLon, minLon, maxLat, minLat);
    CLLocationCoordinate2D center;
    center.longitude = (maxLon + minLon)/2;
    center.latitude = (maxLat + minLat)/2;
    self.center = center;
//    NSLog(@"center %f %f",center.longitude, center.latitude);
    MKCoordinateSpan span;
    span.longitudeDelta = maxLon - minLon;
    span.latitudeDelta = maxLat - minLat;
    self.span = span;
//    NSLog(@"span %f %f",span.longitudeDelta, span.latitudeDelta);
    [self updateMapView];
}

- (void)addPhotoToRecentPhotosList:(NSDictionary *)photo {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotosList = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!recentPhotosList) recentPhotosList = [NSMutableArray array];
    NSString *currentPhotoID = [photo objectForKey:FLICKR_PHOTO_ID];
    BOOL duplicate = NO;
    for (int i = 0; i < recentPhotosList.count; i++) {
        NSString *photoID = [[recentPhotosList objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [recentPhotosList insertObject:photo atIndex:0];
    if (recentPhotosList.count > MAX_NUMBER_OF_PHOTOS) {
        NSRange range;
        range.location = MAX_NUMBER_OF_PHOTOS;
        range.length = recentPhotosList.count - range.location;
        [recentPhotosList removeObjectsInRange:range];
    }
    [defaults setObject:recentPhotosList forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
//    NSLog(@"viewForAnnotation");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        pinView.pinColor = MKPinAnnotationColorRed;
//        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            FlickrAnnotation *flickrAnnotation = pinView.annotation;
            UIImage *thumb = [FlickrCache checkingCacheForThumb:flickrAnnotation.object];
            [(UIImageView *)pinView.leftCalloutAccessoryView setImage:thumb];
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_queue_t cacheCheckingQueue = dispatch_queue_create("cache cheking", NULL);
                dispatch_async(cacheCheckingQueue, ^{
                    if (!self.checkingCache) {
                        self.checkingCache = YES;
                        [FlickrCache checkNumberOfThumbsInCache];
                    }
                    self.checkingCache = NO;
                });
                dispatch_release(cacheCheckingQueue);
            });
        });
        dispatch_release(downloadQueue);
    }
    pinView.annotation = annotation;
    return pinView;
}

- (PhotoViewController *)splitViewPhotoViewController{
    
    id phvc = [self.splitViewController.viewControllers lastObject];
    if (![phvc isKindOfClass:[PhotoViewController class]]) {
        phvc = nil;
    }
    return phvc;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    FlickrAnnotation *flickrAnnotation = view.annotation;
    self.selectedObject = flickrAnnotation.object;
    self.nextTitle = flickrAnnotation.title;
    if ([flickrAnnotation.objType isEqualToString:@"place"]) {
        [self performSegueWithIdentifier:@"nextMapView" sender:self];        
    } else {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            self.image = [FlickrCache checkingCacheForPhoto:self.selectedObject];
            [self addPhotoToRecentPhotosList:self.selectedObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                if ([self splitViewPhotoViewController]) {
                    [[self splitViewPhotoViewController].photoTitle setText:self.nextTitle];
                    [self splitViewPhotoViewController].photo = self.image;
                } else {
                    [self performSegueWithIdentifier:@"showPhotoView" sender:self];
                }
            });
        });
    }
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
//{
//    NSLog(@"didSelectAnnotationView");
//    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
//    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    self.mapView.delegate = nil;
    [self setMapView:nil];
    [self setMapSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSArray *)mapAnnotationsFor:(NSArray *)photos
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[photos count]];
    for (NSDictionary *photo in photos) {
        [annotations addObject:[FlickrAnnotation createAnnotationFor:photo objectType:@"photo"]];
    }
    return annotations;
}

//- (UIImage *)getImageForPhoto:(NSDictionary *)photo {
//    
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"nextMapView"]) {
        
//        NSLog(@"prepareForSegue nextMapView");
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSArray *recentPhotosFromPlace = [FlickrFetcher photosInPlace:self.selectedObject maxResults:50];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
                    MapViewController *mapVC = segue.destinationViewController;
                    mapVC.annotations = [self mapAnnotationsFor:recentPhotosFromPlace];
                }
            });
        });
        dispatch_release(downloadQueue);
        [segue.destinationViewController setTitle:self.nextTitle];
        
    } else if ([segue.identifier isEqualToString:@"showPhotoView"]) {
//        NSLog(@"prepareForSegue showPhotoView");
        [segue.destinationViewController setPhoto:self.image];
        [segue.destinationViewController setTitle:self.nextTitle];
        
    }
}

@end
