//
//  Tag.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/19/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Vacation;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tagID;
@property (nonatomic, retain) Vacation *vacation;

@end
