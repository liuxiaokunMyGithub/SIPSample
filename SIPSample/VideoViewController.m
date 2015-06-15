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

//----11-----17--第二步
- (void)checkDisplayVideo
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (isInitVideo && !appDelegate.isConference) {
        NSLog(@"isStartVideo = %hhd",isStartVideo);
        if(isStartVideo)
        {NSLog(@"sessionId 是%ld",sessionId);
            [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:_viewRemoteVideo];
            [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
            [portSIPSDK displayLocalVideo:YES];
            [portSIPSDK sendVideo:sessionId sendState:YES];
            startVideoOrientation = [UIApplication sharedApplication].statusBarOrientation;
        }
        else
        {
            [portSIPSDK displayLocalVideo:NO];//第一次
            [portSIPSDK setLocalVideoWindow:nil];
            [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:nil];
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
    isInitVideo = YES;
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

//>=iOS6-----点击video视图时第一步回到这里
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
        [portSIPSDK setVideoOrientation:[self getVideoOrotation]];
        [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
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
        [portSIPSDK setLoudspeakerStatus:YES];
        [buttonSpeaker setTitle:@"Headphone" forState: UIControlStateNormal];
    }
    else
    {
        [portSIPSDK setLoudspeakerStatus:NO];
        [buttonSpeaker setTitle:@"Speaker" forState: UIControlStateNormal];
    }
}

- (IBAction) onSwitchCameraClick: (id)sender
{
    UIButton* buttonCamera = (UIButton*)sender;
    [portSIPSDK setLocalVideoWindow:nil];
    
    if([[[buttonCamera titleLabel] text] isEqualToString:@"FrontCamera"])
    {
        [portSIPSDK setVideoDeviceId:1];
        [buttonCamera setTitle:@"BackCamera" forState: UIControlStateNormal];
    }
    else
    {
        [portSIPSDK setVideoDeviceId:0];
        [buttonCamera setTitle:@"FrontCamera" forState: UIControlStateNormal];
    }

    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.isConference) {
        [portSIPSDK setConferenceVideoWindow:nil];
        [portSIPSDK setConferenceVideoWindow:_viewRemoteVideo];
    }
    [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
}

- (IBAction) onSendingVideoClick: (id)sender
{
    UIButton* buttonSendingVideo = (UIButton*)sender;
    
    if([[[buttonSendingVideo titleLabel] text] isEqualToString:@"PauseSending"])
    {
        [portSIPSDK sendVideo:sessionId sendState:NO];

        [buttonSendingVideo setTitle:@"StartSending" forState: UIControlStateNormal];
    }
    else
    {
        [portSIPSDK sendVideo:sessionId sendState:YES];
        [buttonSendingVideo setTitle:@"PauseSending" forState: UIControlStateNormal];
    }
}
- (IBAction)onConference:(id)sender {
    UIButton* buttonConference = (UIButton*)sender;
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if([[[buttonConference titleLabel] text] isEqualToString:@"Conference"])
    {
        [appDelegate createConference:_viewRemoteVideo];
        
        [buttonConference setTitle:@"UnConference" forState: UIControlStateNormal];
    }
    else
    {
        [appDelegate destoryConference:_viewRemoteVideo];
        [portSIPSDK setLocalVideoWindow:nil];
        [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
        [buttonConference setTitle:@"Conference" forState: UIControlStateNormal];
    }
}

//--------10-----16---开始视频--
//接听方法调用之后到这里
- (void)onStartVideo:(long)sessionID
{
    isStartVideo = YES;
    sessionId = sessionID; 
    [self checkDisplayVideo];

}

- (void)onStopVideo:(long)sessionId
{
    isStartVideo = NO;
    [self checkDisplayVideo];
}

@end
