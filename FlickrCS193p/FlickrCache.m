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
#define MAX_SIZE_OF_CACHE_IN_MB 2


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
        thumb = thumbData ? [UIImage imageWithData:thumbData] : nil;
        [[NSFileManager defaultManager] createFileAtPath:filePath
                                                contents:thumbData
                                              attributes:nil];
        
    }
    return thumb;
    
}

+ (UIImage *)checkingCacheForPhoto:(NSDictionary *)photo {
    
    NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
    UIImage *image;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PhotoCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *filePath = [dataPath stringByAppendingPathComponent:photoID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        image = [UIImage imageWithContentsOfFile:filePath];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:2]];
        image = imageData ? [UIImage imageWithData:imageData] : nil;
        [[NSFileManager defaultManager] createFileAtPath:filePath
                                                contents:imageData
                                              attributes:nil];
        [self checkCacheSize:dataPath];
    }
    return image;
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
//        NSLog(@"file removed");
    } else {
//        NSLog(@"no need to remove files");
    }
    
}

+ (void)checkCacheSize:(NSString *)cachePath {
    
    if ([self folderSize:cachePath] > MAX_SIZE_OF_CACHE_IN_MB * 1024 * 1024) {
//        NSLog(@"Need to clean");
        NSArray *filesPathArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
        NSEnumerator *filesEnumerator = [filesPathArray objectEnumerator];
        NSString *fileName;
        NSMutableArray *filesAttributeArray = [NSMutableArray array];
        
        while (fileName = [filesEnumerator nextObject]) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSMutableDictionary *fileDic = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] mutableCopy];
            [fileDic setValue:fileName forKey:@"FileName"];
            [filesAttributeArray addObject:fileDic];
        }
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"NSFileModificationDate" ascending:NO]];
        filesAttributeArray = [[filesAttributeArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        NSString *fileNameToDelete = [[filesAttributeArray lastObject] objectForKey:@"FileName"];
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileNameToDelete];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [self checkCacheSize:cachePath];
    } else {
//        NSLog(@"No need to clean");
    }
}

+ (int)folderSize:(NSString *)folderPath {
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}


@end
