//
//  FlickrCache.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/24/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrCache : NSObject

+ (UIImage *)checkingCacheForThumb:(NSDictionary *)photo;
+ (void)checkNumberOfThumbsInCache;

@end
