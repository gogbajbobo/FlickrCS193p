//
//  PhotoViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/18/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize photoURL = _photoURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setPhotoURL:(NSURL *)photoURL
{
    _photoURL = photoURL;
    [self showPhoto];
}

- (void)showPhoto
{
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoURL]];
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    float yScale;
    float xScale;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        int navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        float height;
        float width;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            height = self.view.bounds.size.height;
            width = self.view.bounds.size.width;
        } else {
            height = self.view.bounds.size.width;
            width = self.view.bounds.size.height;
        }
        yScale = (height - (navigationBarHeight + tabBarHeight)) / self.scrollView.contentSize.height;
        xScale = width / self.scrollView.contentSize.width;        
    } else {
        float height;
        float width;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            height = self.view.bounds.size.height;
            width = self.view.bounds.size.width;
        } else {
            height = self.view.bounds.size.width;
            width = self.view.bounds.size.height;
        }
        yScale = height / self.scrollView.contentSize.height;
        xScale = width / self.scrollView.contentSize.width;
    }
    
    float zoomScale = (xScale < yScale) ? yScale : xScale;
    [self.scrollView setZoomScale:zoomScale];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    [self showPhoto];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
