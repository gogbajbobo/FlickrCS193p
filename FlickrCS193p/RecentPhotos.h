//
//  RecentPhotos.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/18/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotos : NSObject
@property (strong, nonatomic) NSMutableArray *recentPhotos;

- (void)addPhotoToRecentPhotosList:(NSDictionary *)photo;

@end
