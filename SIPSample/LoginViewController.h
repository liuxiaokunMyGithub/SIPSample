//
//  FirstViewController.h
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PortSIPLib/PortSIPSDK.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>{
@public
    PortSIPSDK *portSIPSDK;
    
@protected
    
    BOOL    sipInitialized;
    BOOL    sipRegistered;

}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UIView  *viewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelDebugInfo;

@property (retain, nonatomic) IBOutlet UITextField *textUsername;
@property (retain, nonatomic) IBOutlet UITextField *textPassword;
@property (retain, nonatomic) IBOutlet UITextField *textUserDomain;
@property (retain, nonatomic) IBOutlet UITextField *textSIPserver;
@property (retain, nonatomic) IBOutlet UITextField *textSIPPort;
@property (retain, nonatomic) IBOutlet UITextField *textAuthname;

- (IBAction) onOnlineButtonClick: (id)sender;
- (IBAction) onOfflineButtonClick: (id)sender;

- (int)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText;
- (int)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText;
@end
