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
    self.recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!self.recentPhotos) self.recentPhotos = [NSMutableArray array];

    NSNumber *currentPhotoID = [photo objectForKey:@"id"];
    BOOL duplicate = NO;
    for (int i = 0; i < self.recentPhotos.count; i++) {
        NSNumber *photoID = [[self.recentPhotos objectAtIndex:i] objectForKey:@"id"];
        if ([photoID isEqualToNumber:currentPhotoID]) duplicate = YES;
    }
    if (!duplicate) [self.recentPhotos insertObject:photo atIndex:0];
    [defaults setObject:self.recentPhotos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
    NSLog(@"recentPhotosList %@", self.recentPhotos);
}

@end
