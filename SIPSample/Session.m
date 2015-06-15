//
//  Session.m
//  SIPSample
//
//  Created by Joe Lepple on 5/1/15.
//  Copyright (c) 2015 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import <PortSIPLib/PortSIPSDK.h>

@implementation Session

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset
{
    _sessionId = INVALID_SESSION_ID;
    _holdState = NO;
    _sessionState = NO;
    _conferenceState = NO;
    _recvCallState = NO;
    _isReferCall = NO;
    _originCallSessionId = INVALID_SESSION_ID;
    _existEarlyMedia = NO;
    _videoState = NO;
}

@end