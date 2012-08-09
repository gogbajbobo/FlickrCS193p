//
//  VacationsTableViewController.h
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/9/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface VacationsTableViewController : CoreDataTableViewController

@property (nonatomic, strong) UIManagedDocument *vacationDatabase;

@end
