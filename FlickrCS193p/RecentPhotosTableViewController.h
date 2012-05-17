//
//  RecentPhotosTableViewController.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/16/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecentPhotosTVCDataSource <NSObject>

- (NSArray *)recentPhotos:(int)rowOfPlace;

@end

@interface RecentPhotosTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *recentPhotos;
@property (weak, nonatomic) IBOutlet id <RecentPhotosTVCDataSource> recentPhotosDataSource;

@end
