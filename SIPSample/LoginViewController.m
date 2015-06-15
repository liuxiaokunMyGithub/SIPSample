//
//  FirstViewController.m
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "LoginViewController.h"
#include "AppDelegate.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
    
@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _textUsername.delegate = self;
    _textPassword.delegate = self;
    _textUserDomain.delegate = self;
    _textSIPserver.delegate = self;
    _textSIPPort.delegate = self;
    _textAuthname.delegate = self;
    
    sipInitialized = NO;
    sipRegistered  = NO;
    [_labelDebugInfo setText:@"PortSIP VoIP SDK for iOS"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyboardWillShow:(NSNotification *)noti
{
    float height = 216.0;
    CGRect frame = self.view.frame;    
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);    
    [UIView beginAnimations:@"Curl" context:nil];    
    [UIView setAnimationDuration:0.30];    
    [UIView setAnimationDelegate:self];    
    [self.view setFrame:frame];     
    [UIView commitAnimations];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];    
    [UIView setAnimationDuration:animationDuration];    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);    
    self.view.frame = rect;    
    [UIView commitAnimations];    
    [textField resignFirstResponder];    
    return YES;    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;    
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);    
    NSTimeInterval animationDuration = 0.30f;    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;    
    float height = self.view.frame.size.height;
    
    if(offset > 0)        
    {    
        CGRect rect = CGRectMake(0.0f, -offset,width,height);        
        self.view.frame = rect;               
    }           
    [UIView commitAnimations];               
}

//------3--登录
- (IBAction) onOnlineButtonClick: (id)sender
{
    if(sipInitialized)
    {
        [_labelDebugInfo setText:@"You already registered, Offline first!"];
        return;
    }
    
    NSString* kUserName = _textUsername.text;
    NSString* kDisplayName = _textUsername.text;
    NSString* kAuthName = _textAuthname.text;
    NSString* kPassword = _textPassword.text;
    NSString* kUserDomain = _textUserDomain.text;
    NSString* kSIPServer = _textSIPserver.text;
    int kSIPServerPort = [_textSIPPort.text intValue];
    
    
    if([kUserName length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter user name!"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if([kPassword length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter password"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if([kSIPServer length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter SIP Server!"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
//初始化SDK释放资源
    int ret = [portSIPSDK initialize:TRANSPORT_UDP loglevel:PORTSIP_LOG_NONE logPath:@"" maxLine:8 agent:@"PortSIP SDK for IOS" audioDeviceLayer:0 videoDeviceLayer:0];
        
    if(ret != 0)
    {
        NSLog(@"initialize failure ErrorCode = %d",ret);
        return ;
    }
    
    int localPort = 10000 + arc4random()%1000;
    NSString* loaclIPaddress = @"0.0.0.0";//Auto select IP address
    
    [portSIPSDK setUser:kUserName displayName:kDisplayName authName:kAuthName password:kPassword localIP:loaclIPaddress localSIPPort:localPort userDomain:kUserDomain SIPServer:kSIPServer SIPServerPort:kSIPServerPort STUNServer:@"" STUNServerPort:0 outboundServer:@"" outboundServerPort:0];

    
    int rt = [portSIPSDK setLicenseKey:@"PORTSIP_TEST_LICENSE"];
    if (rt == ECoreTrialVersionLicenseKey)
	{
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"This trial version SDK just allows short conversation, you can't heairng anyting after 2-3 minutes, contact us: sales@portsip.com to buy official version."
                              delegate: self
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
	}
	else if (rt == ECoreWrongLicenseKey)
	{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message: @"The wrong license key was detected, please check with sales@portsip.com or support@portsip.com"
                              delegate: self
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"setLicenseKey failure ErrorCode = %d",rt);
        return ;
	}

    
    [portSIPSDK addAudioCodec:AUDIOCODEC_PCMA];
    [portSIPSDK addAudioCodec:AUDIOCODEC_PCMU];
    [portSIPSDK addAudioCodec:AUDIOCODEC_SPEEX];
    [portSIPSDK addAudioCodec:AUDIOCODEC_G729];
    
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_GSM];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_ILBC];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_AMR];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_SPEEXWB];
	
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263];
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263_1998];
    [portSIPSDK addVideoCodec:VIDEO_CODEC_H264];
    
    [portSIPSDK setVideoBitrate:100];//video send bitrate,100kbps
    [portSIPSDK setVideoFrameRate:10];
    [portSIPSDK setVideoResolution:VIDEO_CIF];
    [portSIPSDK setAudioSamples:20 maxPtime:60];//ptime 20
    
    //1 - FrontCamra 0 - BackCamra
    [portSIPSDK setVideoDeviceId:1];
    
    //enable srtp
    //[mPortSIPSDK setSrtpPolicy:SRTP_POLICY_FORCE];
    
	// Try to register the default identity
    [portSIPSDK registerServer:90 retryTimes:0];
    
    [_activityIndicator startAnimating];
    
    [_labelDebugInfo setText:@"Registration..."];
    NSString* sipURL = nil;
    if(kSIPServerPort == 5060)
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@",kUserName,kUserDomain];
    else
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@:%d",kUserName,kUserDomain,kSIPServerPort];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.sipURL = sipURL;
    
    sipInitialized = YES;
    
    
};

- (IBAction) onOfflineButtonClick: (id)sender
{
    if(sipInitialized)
    {
        [portSIPSDK unRegisterServer];
        [portSIPSDK unInitialize];
        [_viewStatus setBackgroundColor:[UIColor redColor]];
        
        [_labelStatus setText:@"Not Connected"];
        [_labelDebugInfo setText:[NSString stringWithFormat: @"unRegisterServer"]];
        
        sipRegistered = NO;
        sipInitialized = NO;
    }
    if([_activityIndicator isAnimating])
        [_activityIndicator stopAnimating];
};

//--------5----
- (int)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText
{
    [_viewStatus setBackgroundColor:[UIColor greenColor]];
    
    [_labelStatus setText:@"Connected"];
    
    [_labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterSuccess: %s", statusText]];
    
    [_activityIndicator stopAnimating];
    
    sipRegistered = YES;
    return 0;
}


- (int)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText
{
    [_viewStatus setBackgroundColor:[UIColor redColor]];
    
    [_labelStatus setText:@"Not Connected"];
    
    [_labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterFailure: %s", statusText]];
    
    [_activityIndicator stopAnimating];
    
    sipRegistered = NO;
    return 0;
};
@end
