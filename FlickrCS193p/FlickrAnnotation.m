//
//  FlickrAnnotation.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/23/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "FlickrAnnotation.h"
#import "FlickrFetcher.h"

@interface FlickrAnnotation()

@end

@implementation FlickrAnnotation

@synthesize objType = _objType;
@synthesize object = _object;

+ (FlickrAnnotation *)createAnnotationFor:(NSDictionary *)object
                               objectType:(NSString *)objType
{
    FlickrAnnotation *annotation = [[FlickrAnnotation alloc] init];
    annotation.object = object;
    annotation.objType = objType;
    return annotation;
}

- (NSString *)title
{
    if ([self.objType isEqualToString:@"place"]) {
        return [self.object objectForKey:FLICKR_PLACE_NAME];
    } else {
        return [self.object objectForKey:FLICKR_PHOTO_TITLE];
    }
}

- (NSString *)subtitle
{
    if ([self.objType isEqualToString:@"place"]) {
        return [self.object objectForKey:FLICKR_PHOTO_COUNT];
    } else {
        return [[self.object valueForKey:FLICKR_PHOTO_DESCRIPTION] valueForKey:FLICKR_PLACE_NAME];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.object objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.object objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
