//
//  VacationsTableViewController.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 8/9/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "VacationsTableViewController.h"

@interface VacationsTableViewController ()

@end

@implementation VacationsTableViewController

@synthesize vacationDatabase = _vacationDatabase;


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}


@end
