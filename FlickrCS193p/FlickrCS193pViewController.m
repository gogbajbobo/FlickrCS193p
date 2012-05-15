//
//  FlickrCS193pViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/15/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "FlickrCS193pViewController.h"
#import "FlickrFetcher.h"

@interface FlickrCS193pViewController ()

@end

@implementation FlickrCS193pViewController


- (void)getTopPlaces
{
    NSArray *topPlaces = [FlickrFetcher topPlaces];
    NSLog(@"TP %@", topPlaces);
}




// ____________________________________________________

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTopPlaces];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
