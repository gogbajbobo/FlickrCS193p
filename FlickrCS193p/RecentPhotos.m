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

#define RECENT_PHOTOS_KEY @"Flickr.recentPhotos"
#define MAX_NUMBER_OF_PHOTOS 50

- (NSMutableArray *)recentPhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!_recentPhotos) _recentPhotos = [NSMutableArray array];
    return _recentPhotos;
}

- (void)addPhotoToRecentPhotosList:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!recentPhotos) recentPhotos = [NSMutableArray array];

    NSString *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < recentPhotos.count; i++) {
        NSString *photoID = [[recentPhotos objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToString:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [recentPhotos insertObject:photo atIndex:0];
    NSLog(@"count %d", recentPhotos.count);
    if (recentPhotos.count > MAX_NUMBER_OF_PHOTOS) {
        NSRange range;
        range.location = MAX_NUMBER_OF_PHOTOS - 1;
        range.length = recentPhotos.count - MAX_NUMBER_OF_PHOTOS;
        NSLog(@"range %d %d", range.location, range.length);
        [recentPhotos removeObjectsInRange:range];
        NSLog(@"count %d", recentPhotos.count);
    }
    [defaults setObject:recentPhotos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

@end
