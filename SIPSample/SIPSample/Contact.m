//
//  Contact.m
//  SIPSample
//
//  Created by Joe Lepple on 6/14/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "Contact.h"

@implementation Contact
@synthesize subscribeID;
@synthesize sipURL;
@synthesize basicState;
@synthesize note;



-(Contact*) initWithSubscribe:(long)_subscribeid andSipURL:(NSString*)_sipURL
{
    if((self = [super init])){
		self->subscribeID = _subscribeid;
		self->sipURL = _sipURL;
		self->basicState = @"close";
        self->note = nil;
	}
	return self;
}
@end
