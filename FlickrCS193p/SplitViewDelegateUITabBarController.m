//
//  SplitViewDelegateUITabBarController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/21/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "SplitViewDelegateUITabBarController.h"

@interface SplitViewDelegateUITabBarController ()

@end

@implementation SplitViewDelegateUITabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}


//______________________________________________________________________________


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
