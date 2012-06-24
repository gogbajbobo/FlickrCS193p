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
@synthesize thumbnailsCache = _thumbnailsCache;
@synthesize photosCache = _photosCache;

#define RECENT_PHOTOS_KEY @"Flickr.recentPhotos"
#define MAX_NUMBER_OF_PHOTOS 50
#define PHOTOS_CACHE_KEY @"Flickr.photosCache"
#define MAX_PHOTOS_IN_CACHE 50
#define THUMBNAILS_CACHE_KEY @"Flickr.thumbsCache"
#define MAX_THUMBS_IN_CACHE 500

- (NSMutableArray *)recentPhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!_recentPhotos) _recentPhotos = [NSMutableArray array];
    return _recentPhotos;
}

- (NSMutableArray *)thumbnailsCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _thumbnailsCache = [[defaults objectForKey:THUMBNAILS_CACHE_KEY] mutableCopy];
    if (!_thumbnailsCache) _thumbnailsCache = [NSMutableArray array];
    return _thumbnailsCache;
}

- (NSMutableArray *)photosCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _photosCache = [[defaults objectForKey:PHOTOS_CACHE_KEY] mutableCopy];
    if (!_photosCache) _photosCache = [NSMutableArray array];
    return _photosCache;
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
    NSMutableArray *photosCache = self.photosCache;
    
    NSString *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < photosCache.count; i++) {
        NSString *photoID = [[photosCache objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [photosCache insertObject:photo atIndex:0];
    if (photosCache.count > MAX_PHOTOS_IN_CACHE) {
        NSRange range;
        range.location = MAX_PHOTOS_IN_CACHE - 1;
        range.length = photosCache.count - MAX_PHOTOS_IN_CACHE;
        [photosCache removeObjectsInRange:range];
    }
    [defaults setObject:photosCache forKey:PHOTOS_CACHE_KEY];
    [defaults synchronize];
}

- (void)addThumbnailsToCache:(NSDictionary *)thumbnails
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *thumbnailsCache = self.thumbnailsCache;
    
    NSString *currentPhotoID = [thumbnails objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < thumbnailsCache.count; i++) {
        NSString *photoID = [[thumbnailsCache objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [thumbnailsCache insertObject:thumbnails atIndex:0];
    if (thumbnailsCache.count > MAX_THUMBS_IN_CACHE) {
        NSRange range;
        range.location = MAX_THUMBS_IN_CACHE - 1;
        range.length = thumbnailsCache.count - MAX_THUMBS_IN_CACHE;
        [thumbnailsCache removeObjectsInRange:range];
    }
    [defaults setObject:thumbnailsCache forKey:THUMBNAILS_CACHE_KEY];
    [defaults synchronize];    
}

@end
