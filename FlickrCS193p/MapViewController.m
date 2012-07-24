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

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *selectedObject;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize selectedObject = _selectedObject;
//@synthesize delegate = _delegate;

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
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
    }
    pinView.annotation = annotation;
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    FlickrAnnotation *flickrAnnotation = view.annotation;
    self.selectedObject = flickrAnnotation.object;
    if ([flickrAnnotation.objType isEqualToString:@"place"]) {
        [self performSegueWithIdentifier:@"nextMapView" sender:self];        
    } else {
        [self performSegueWithIdentifier:@"showPhotoView" sender:self];
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
        
    } else if ([segue.identifier isEqualToString:@"showPhotoView"]) {
        NSLog(@"prepareForSegue showPhotoView");
    }
}

@end
