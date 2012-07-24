//
//  FlickrCache.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 7/24/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "FlickrCache.h"
#import "FlickrFetcher.h"

#define MAX_NUMBER_OF_THUMBS 100

@implementation FlickrCache

+ (UIImage *)checkingCacheForThumb:(NSDictionary *)photo {

    UIImage *thumb;
    NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *thumbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThumbCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *filePath = [thumbPath stringByAppendingPathComponent:photoID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        thumb = [UIImage imageWithContentsOfFile:filePath];
    } else {
        NSData *thumbData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]];
        if (!thumbData) {
            thumb = nil;
        } else {
            thumb = [UIImage imageWithData:thumbData];
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath
                                                contents:thumbData
                                              attributes:nil];
    }
    return thumb;
}

+ (void)checkNumberOfThumbsInCache {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThumbCache"];

    NSArray *filesPathArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
    if (filesPathArray.count > MAX_NUMBER_OF_THUMBS) {
        NSEnumerator *filesEnumerator = [filesPathArray objectEnumerator];
        NSString *fileName;
        NSMutableArray *filesAttributeArray = [NSMutableArray array];
        
        while (fileName = [filesEnumerator nextObject]) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSMutableDictionary *fileDic = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] mutableCopy];
            if (!fileDic) fileDic = [NSMutableDictionary dictionary];
            [fileDic setValue:fileName forKey:@"FileName"];
            [filesAttributeArray addObject:fileDic];
        }
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"NSFileModificationDate" ascending:NO]];
        filesAttributeArray = [[filesAttributeArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        NSRange range;
        range.location = 0;
        range.length = MAX_NUMBER_OF_THUMBS;
        [filesAttributeArray removeObjectsInRange:range];
        for (int i = 0; i < filesAttributeArray.count; i++) {
            NSString *fileNameToDelete = [[filesAttributeArray objectAtIndex:i] objectForKey:@"FileName"];
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileNameToDelete];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    } else {
        //        NSLog(@"No need to remove files");
    }
    
}



@end
