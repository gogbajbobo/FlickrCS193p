//
//  TopPlacesCell.m
//  FlickrCS193p
//
//  Created by Григорьев Максим on 5/17/12.
//  Copyright (c) 2012 Maxim V. Grigoriev. All rights reserved.
//

#import "TopPlacesCell.h"

@implementation TopPlacesCell
@synthesize row = _row;
@synthesize section = _section;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
