//
//  RecentPhotos.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/18/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "RecentPhotos.h"

@interface RecentPhotos ()

@end

@implementation RecentPhotos
@synthesize recentPhotos = _recentPhotos;
@synthesize photoCache = _photoCache; // <- should be only thumbnails cache, fullsize photo keep in recentPhoto array

#define RECENT_PHOTOS_KEY @"Flickr.recentPhotos"
#define PHOTOS_CACHE_KEY @"Flickr.photosCache"
#define MAX_NUMBER_OF_PHOTOS 50
#define MAX_PHOTOS_IN_CACHE 50

- (NSMutableArray *)recentPhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!_recentPhotos) _recentPhotos = [NSMutableArray array];
    return _recentPhotos;
}

- (NSMutableArray *)photoCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _photoCache = [[defaults objectForKey:PHOTOS_CACHE_KEY] mutableCopy];
    if (!_photoCache) _photoCache = [NSMutableArray array];
    return _photoCache;
}

- (void)addPhotoToRecentPhotosList:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = self.recentPhotos;
    
    NSString *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < recentPhotos.count; i++) {
        NSString *photoID = [[recentPhotos objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [recentPhotos insertObject:photo atIndex:0];
    if (recentPhotos.count > MAX_NUMBER_OF_PHOTOS) {
        NSRange range;
        range.location = MAX_NUMBER_OF_PHOTOS - 1;
        range.length = recentPhotos.count - MAX_NUMBER_OF_PHOTOS;
        [recentPhotos removeObjectsInRange:range];
    }
    [defaults setObject:recentPhotos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

- (void)addPhotoToCache:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photoCache = self.photoCache;
    
    NSString *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < photoCache.count; i++) {
        NSString *photoID = [[photoCache objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [photoCache insertObject:photo atIndex:0];
    if (photoCache.count > MAX_PHOTOS_IN_CACHE) {
        NSRange range;
        range.location = MAX_PHOTOS_IN_CACHE - 1;
        range.length = photoCache.count - MAX_PHOTOS_IN_CACHE;
        [photoCache removeObjectsInRange:range];
    }
    [defaults setObject:photoCache forKey:PHOTOS_CACHE_KEY];
    [defaults synchronize];
    
}

@end
