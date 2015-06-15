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
@synthesize activityIndicator;
@synthesize viewStatus;
@synthesize labelStatus;
@synthesize labelDebugInfo;
@synthesize textUsername;
@synthesize textPassword;
@synthesize textUserDomain;
@synthesize textSIPserver;
@synthesize textSIPPort;
@synthesize textAuthname;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    textUsername.delegate = self;
    textPassword.delegate = self;
    textUserDomain.delegate = self;
    textSIPserver.delegate = self;
    textSIPPort.delegate = self;
    textAuthname.delegate = self;
    
    SIPInitialized = NO;
    SIPRegistered  = NO;
    [labelDebugInfo setText:@"PortSIP VoIP SDK for iOS"];
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

- (IBAction) onOnlineButtonClick: (id)sender
{
    if(SIPInitialized)
    {
        [labelDebugInfo setText:@"You already registered, Offline first!"];
        return;
    }
    
    NSString* kUserName = textUsername.text;
    NSString* kDisplayName = textUsername.text;
    NSString* kAuthName = textAuthname.text;
    NSString* kPassword = textPassword.text;
    NSString* kUserDomain = textUserDomain.text;
    NSString* kSIPServer = textSIPserver.text;
    int kSIPServerPort = [textSIPPort.text intValue];
    
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
    
    int ret = [mPortSIPSDK initialize:TRANSPORT_UDP loglevel:PORTSIP_LOG_NONE logPath:NULL maxLine:8 agent:@"PortSIP SDK for IOS" audioDeviceLayer:0 videoDeviceLayer:0];
        
    if(ret != 0)
    {
        NSLog(@"initialize failure ErrorCode = %d",ret);
        return ;
    }
    
    int localPort = 10000 + arc4random()%1000;
    NSString* loaclIPaddress = @"0.0.0.0";//Auto select IP address
    
    [mPortSIPSDK setUser:kUserName displayName:kDisplayName authName:kAuthName password:kPassword localIP:loaclIPaddress localSIPPort:localPort userDomain:kUserDomain SIPServer:kSIPServer SIPServerPort:kSIPServerPort STUNServer:@"" STUNServerPort:0 outboundServer:@"" outboundServerPort:0];

    
    int rt = [mPortSIPSDK setLicenseKey:@"PORTSIP_TEST_LICENSE"];
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

    
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_PCMA];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_PCMU];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_SPEEX];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_G729];
    
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_GSM];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_ILBC];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_AMR];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_SPEEXWB];
	
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263];
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263_1998];
    [mPortSIPSDK addVideoCodec:VIDEO_CODEC_H264];
    
    [mPortSIPSDK setVideoBitrate:100];//video send bitrate,100kbps
    [mPortSIPSDK setVideoFrameRate:10];
    [mPortSIPSDK setVideoResolution:VIDEO_CIF];
    [mPortSIPSDK setAudioSamples:20 maxPtime:60];//ptime 20
    
    //1 - FrontCamra 0 - BackCamra
    [mPortSIPSDK setVideoDeviceId:1];
    
    //enable srtp
    //[mPortSIPSDK setSrtpPolicy:SRTP_POLICY_FORCE];
    
	// Try to register the default identity
    [mPortSIPSDK registerServer:90 retryTimes:0];
    
    [activityIndicator startAnimating];
    
    [labelDebugInfo setText:@"Registration..."];
    NSString* sipURL = nil;
    if(kSIPServerPort == 5060)
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@",kUserName,kUserDomain];
    else
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@:%d",kUserName,kUserDomain,kSIPServerPort];
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.sipURL = sipURL;
    
    SIPInitialized = YES;
};

- (IBAction) onOfflineButtonClick: (id)sender
{
    if(SIPInitialized)
    {
        [mPortSIPSDK unRegisterServer];
        [mPortSIPSDK unInitialize];
        [viewStatus setBackgroundColor:[UIColor redColor]];
        
        [labelStatus setText:@"Not Connected"];
        [labelDebugInfo setText:[NSString stringWithFormat: @"unRegisterServer"]];
        
        SIPRegistered = NO;
        SIPInitialized = NO;
    }
    if([activityIndicator isAnimating])
        [activityIndicator stopAnimating];
};

- (int)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText
{
    [viewStatus setBackgroundColor:[UIColor greenColor]];
    
    [labelStatus setText:@"Connected"];
    
    [labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterSuccess: %s", statusText]];
    
    [activityIndicator stopAnimating];
    
    SIPRegistered = YES;
    return 0;
}


- (int)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText
{
    [viewStatus setBackgroundColor:[UIColor redColor]];
    
    [labelStatus setText:@"Not Connected"];
    
    [labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterFailure: %s", statusText]];
    
    [activityIndicator stopAnimating];
    
    SIPRegistered = NO;
    return 0;
};
@end
