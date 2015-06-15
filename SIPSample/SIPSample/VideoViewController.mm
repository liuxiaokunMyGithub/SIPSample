//
//  VideoViewController.m
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "VideoViewController.h"
#import "AppDelegate.h"

@interface VideoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonConference;


- (void)checkDisplayVideo;
@end

@implementation VideoViewController
@synthesize viewLocalVideo;
@synthesize viewRemoteVideo;

- (void)checkDisplayVideo
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (isInitVideo && !appDelegate.isConference) {
        if(isStartVideo)
        {
            [mPortSIPSDK setRemoteVideoWindow:mSessionId remoteVideoWindow:viewRemoteVideo];
            [mPortSIPSDK setLocalVideoWindow:viewLocalVideo];
            [mPortSIPSDK displayLocalVideo:YES];
            [mPortSIPSDK sendVideo:mSessionId sendState:YES];
            startVideoOrientation = [UIApplication sharedApplication].statusBarOrientation;
        }
        else
        {
            [mPortSIPSDK displayLocalVideo:NO];
            [mPortSIPSDK setLocalVideoWindow:nil];
            [mPortSIPSDK setRemoteVideoWindow:mSessionId remoteVideoWindow:NULL];
        }
        
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isInitVideo = true;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [self checkDisplayVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//<iOS6
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//>=iOS6
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(int)getVideoOrotation
{
    int startVideoOrientationVal = 0;
    switch (startVideoOrientation) {
        case UIInterfaceOrientationPortrait:
            startVideoOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            startVideoOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            startVideoOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            startVideoOrientationVal = 270;
            break;
        default:
            break;
    }
    
    int currentOrientationVal = 0;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            currentOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            currentOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            currentOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            currentOrientationVal = 270;
            break;
        default:
            break;
    }
    
    return (startVideoOrientationVal + 360 - currentOrientationVal)%360;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(isStartVideo)
    {
        [mPortSIPSDK setVideoOrientation:[self getVideoOrotation]];
        [mPortSIPSDK setLocalVideoWindow:viewLocalVideo];
    }
}

- (BOOL) shouldAutorotate {
    
    return YES;
}

- (IBAction) onSwitchSpeakerClick: (id)sender
{
    UIButton* buttonSpeaker = (UIButton*)sender;
    
    if([[[buttonSpeaker titleLabel] text] isEqualToString:@"Speaker"])
    {
        [mPortSIPSDK setLoudspeakerStatus:YES];
        [buttonSpeaker setTitle:@"Headphone" forState: UIControlStateNormal];
    }
    else
    {
        [mPortSIPSDK setLoudspeakerStatus:NO];
        [buttonSpeaker setTitle:@"Speaker" forState: UIControlStateNormal];
    }
}

- (IBAction) onSwitchCameraClick: (id)sender
{
    UIButton* buttonCamera = (UIButton*)sender;
    [mPortSIPSDK setLocalVideoWindow:nil];
    
    if([[[buttonCamera titleLabel] text] isEqualToString:@"FrontCamera"])
    {
        [mPortSIPSDK setVideoDeviceId:1];
        [buttonCamera setTitle:@"BackCamera" forState: UIControlStateNormal];
    }
    else
    {
        [mPortSIPSDK setVideoDeviceId:0];
        [buttonCamera setTitle:@"FrontCamera" forState: UIControlStateNormal];
    }

    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.isConference) {
        [mPortSIPSDK setConferenceVideoWindow:nil];
        [mPortSIPSDK setConferenceVideoWindow:viewRemoteVideo];
    }
    [mPortSIPSDK setLocalVideoWindow:viewLocalVideo];
}

- (IBAction) onSendingVideoClick: (id)sender
{
    UIButton* buttonSendingVideo = (UIButton*)sender;
    
    if([[[buttonSendingVideo titleLabel] text] isEqualToString:@"PauseSending"])
    {
        [mPortSIPSDK sendVideo:mSessionId sendState:FALSE];

        [buttonSendingVideo setTitle:@"StartSending" forState: UIControlStateNormal];
    }
    else
    {
        [mPortSIPSDK sendVideo:mSessionId sendState:TRUE];
        [buttonSendingVideo setTitle:@"PauseSending" forState: UIControlStateNormal];
    }
}
- (IBAction)onConference:(id)sender {
    UIButton* buttonConference = (UIButton*)sender;
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if([[[buttonConference titleLabel] text] isEqualToString:@"Conference"])
    {
        [appDelegate createConference:viewRemoteVideo];
        
        [buttonConference setTitle:@"UnConference" forState: UIControlStateNormal];
    }
    else
    {
        [appDelegate destoryConference:viewRemoteVideo];
        [mPortSIPSDK setLocalVideoWindow:nil];
        [mPortSIPSDK setLocalVideoWindow:viewLocalVideo];
        [buttonConference setTitle:@"Conference" forState: UIControlStateNormal];
    }
}

- (void)onStartVideo:(long)sessionId
{
    isStartVideo = YES;
    mSessionId = sessionId;
    [self checkDisplayVideo];

}

- (void)onStopVideo:(long)sessionId
{
    isStartVideo = NO;
    [self checkDisplayVideo];
}

@end
