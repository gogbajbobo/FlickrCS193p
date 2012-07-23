//
//  FlickrAnnotation.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/23/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "FlickrAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrAnnotation

@synthesize place = _place;

+ (FlickrAnnotation *)annotationForPlace:(NSDictionary *)place {
    FlickrAnnotation *annotation = [[FlickrAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSString *)title
{
    return [self.place objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *)subtitle
{
    return  [self.place objectForKey:FLICKR_PHOTO_OWNER];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
