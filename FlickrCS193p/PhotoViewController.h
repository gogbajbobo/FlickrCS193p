//
//  PhotoViewController.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/18/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoViewController : UIViewController <SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) UIImage *photo;

@end
