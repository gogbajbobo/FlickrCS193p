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
@property (nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize photo = _photo;
@synthesize photoTitle = _photoTitle;


- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setPhoto:(UIImage *)photo
{
    _photo = photo;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self showPhoto];
    }
}

- (void)showPhoto
{
    self.imageView.image = self.photo;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    float yScale;
    float xScale;
    float height;
    float width;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        height = self.view.bounds.size.height;
        width = self.view.bounds.size.width;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) height = height - self.toolbar.frame.size.height;
    } else {
        height = self.view.bounds.size.width;
        width = self.view.bounds.size.height;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        int navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        yScale = (height - (navigationBarHeight + tabBarHeight)) / self.scrollView.contentSize.height;
        xScale = width / self.scrollView.contentSize.width;
    } else {
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self showPhoto];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setTitle:nil];
    [self setPhotoTitle:nil];
    [self setPhotoTitle:nil];
    [self setPhotoTitle:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
