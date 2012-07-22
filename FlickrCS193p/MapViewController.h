//
//  MapViewController.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/22/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
