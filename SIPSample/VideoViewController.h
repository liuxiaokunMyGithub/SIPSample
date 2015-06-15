//
//  VideoViewController.h
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PortSIPLib/PortSIPSDK.h>

@interface VideoViewController : UIViewController{
@public
    PortSIPSDK *portSIPSDK;
    
@protected
    BOOL    isStartVideo;
    BOOL    isInitVideo;
    long    sessionId;
    UIInterfaceOrientation startVideoOrientation;
}


@property (retain, nonatomic) IBOutlet UIView* viewLocalVideo;
@property (retain, nonatomic) IBOutlet UIView *viewRemoteVideo;

- (IBAction) onSwitchSpeakerClick: (id)sender;
- (IBAction) onSwitchCameraClick: (id)sender;
- (IBAction) onSendingVideoClick: (id)sender;

- (void)onStartVideo:(long)sessionId;
- (void)onStopVideo:(long)sessionId;

@end
