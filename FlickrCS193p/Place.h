//
//  Place.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/19/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Vacation;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * placeURL;
@property (nonatomic, retain) Vacation *vacation;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
