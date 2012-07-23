//
//  MapViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/22/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>


@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
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
    NSLog(@"viewForAnnotation");
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        pinView.pinColor = MKPinAnnotationColorRed;
//        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    pinView.annotation = annotation;
//    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return pinView;
//    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"calloutAccessoryControlTapped");
    [self performSegueWithIdentifier:@"nextMapView" sender:self];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"nextMapView"]) {
        NSLog(@"prepareForSegue nextMapView");
    }
}

@end
