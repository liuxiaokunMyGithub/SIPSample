//
//  AppDelegate.h
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PortSIPLib/PortSIPSDK.h>

#import "LoginViewController.h"
#import "NumpadViewController.h"
#import "VideoViewController.h"
#import "IMViewController.h"
#import "SettingsViewController.h"
#import "Session.h"
#import "LineTableViewController.h"

#define shareAppDelegate      [AppDelegate sharedInstance]

@interface AppDelegate : UIResponder <UIApplicationDelegate,PortSIPEventDelegate,UIAlertViewDelegate,LineViewControllerDelegate>
{
    PortSIPSDK* mPortSIPSDK;
    LoginViewController* loginViewController;
    NumpadViewController* numpadViewController;
    VideoViewController* videoViewController;
    IMViewController* imViewController;
    SettingsViewController* settingsViewController;
    
    Session     mSessionArray[MAX_LINES];
    BOOL        mSIPRegistered;
    NSString    *sipURL;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSString *sipURL;
@property NSInteger    mActiveLine;
@property (nonatomic, assign) BOOL isConference;

- (void) pressNumpadButton:(char )dtmf;
- (void) makeCall:(NSString*) callee
   videoCall:(BOOL)videoCall;
- (void) hungUpCall;
- (void) holdCall;
- (void) unholdCall;
- (void) referCall:(NSString*)referTo;
- (void) muteCall:(BOOL)mute;
- (void) setLoudspeakerStatus:(BOOL)enable;
- (void) switchSessionLine;


- (BOOL)createConference:(UIView *)conferenceVideoWindow;
- (void)removeFromConference:(long)sessionId;
- (void)setConferenceVideoWindow:(UIView*) conferenceVideoWindow;
- (BOOL)joinToConference:(long)sessionId;
- (void)destoryConference:(UIView *)viewRemoteVideo;
@end
