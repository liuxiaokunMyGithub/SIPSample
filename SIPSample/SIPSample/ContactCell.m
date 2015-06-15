//
//  ContactCell.m
//  SIPSample
//
//  Created by Joe Lepple on 6/14/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell
@synthesize urlLabel;
@synthesize noteLabel;
@synthesize onlineImageView;

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
