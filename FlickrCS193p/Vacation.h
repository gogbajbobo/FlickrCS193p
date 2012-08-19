//
//  Vacation.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/19/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Vacation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * vacID;
@property (nonatomic, retain) NSSet *itenerary;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Vacation (CoreDataGeneratedAccessors)

- (void)addIteneraryObject:(Place *)value;
- (void)removeIteneraryObject:(Place *)value;
- (void)addItenerary:(NSSet *)values;
- (void)removeItenerary:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
