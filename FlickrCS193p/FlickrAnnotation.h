//
//  FlickrAnnotation.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/23/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FlickrAnnotation : NSObject <MKAnnotation>

+ (FlickrAnnotation *)createAnnotationFor:(NSDictionary *)object
                               objectType:(NSString *)objType;

@property (nonatomic, strong) NSDictionary *object;

@end
