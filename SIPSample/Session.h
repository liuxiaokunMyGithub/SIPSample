/*
    PortSIP 11.2
    Copyright (C) 2014 PortSIP Solutions, Inc.
   
    support@portsip.com

    Visit us at http://www.portsip.com
*/

#define LINE_BASE 0
#define MAX_LINES 8

@interface Session : NSObject 
@property (nonatomic, assign) long sessionId;
@property (nonatomic, assign) BOOL holdState;
@property (nonatomic, assign) BOOL sessionState;
@property (nonatomic, assign) BOOL conferenceState;
@property (nonatomic, assign) BOOL recvCallState;
@property (nonatomic, assign) BOOL isReferCall;
@property (nonatomic, assign) long originCallSessionId;
@property (nonatomic, assign) BOOL existEarlyMedia;
@property (nonatomic, assign) BOOL videoState;

- (void)reset;
@end

