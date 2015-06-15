//
//  SecondViewController.m
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "NumpadViewController.h"
#import "LineTableViewController.h"
#import "AppDelegate.h"

#define kTAGStar		10
#define kTAGSharp		11

#define kTAGVideoCall	12
#define kTAGAudioCall	13
#define kTAGHangUp      14

#define kTAGHold		15
#define kTAGUnHold		16
#define kTAGRefer		17

#define kTAGMute		18
#define kTAGSpeak		19
#define kTAGConfer      20

#define kTAGDelete		21

@interface NumpadViewController ()

@end

@implementation NumpadViewController
@synthesize textNumber;
@synthesize labelStatus;
@synthesize buttonLine;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textNumber.delegate = self;
    
    [labelStatus setText:@""];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [buttonLine setTitle:[NSString  stringWithFormat:@"Line%ld:", appDelegate.mActiveLine] forState:UIControlStateNormal];
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction) onButtonClick: (id)sender
{
    NSInteger tag = ((UIButton*)sender).tag;
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

	switch (tag) {
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
        {
			textNumber.text = [textNumber.text stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)tag]];
            
            char dtmf = tag;
            [appDelegate pressNumpadButton:dtmf];
        }
			break;
        case kTAGStar:
        {
			textNumber.text = [textNumber.text stringByAppendingString:@"*"];
            [appDelegate pressNumpadButton:10];
        }
			break;
			
		case kTAGSharp:
        {
			textNumber.text = [textNumber.text stringByAppendingString:@"#"];
            [appDelegate pressNumpadButton:11];
        }
			break;
        case kTAGDelete:
		{
			NSString* number = textNumber.text;
			if([number length] >0){
                textNumber.text = [number substringToIndex:([number length]-1)];
			}
			break;
		}
        case kTAGVideoCall:
        {
            [appDelegate makeCall:[textNumber text] videoCall:true];
            break;
        }
        case kTAGAudioCall:
        {
            [appDelegate makeCall:[textNumber text] videoCall:false];
            break;
        }

        case kTAGHangUp:
        {
            [appDelegate hungUpCall];
            break;
        }
        case kTAGHold:
        {
            [appDelegate holdCall];
            break;
        }
        case kTAGUnHold:
        {
            [appDelegate unholdCall];
            break;
        }
            
        case kTAGRefer:
        {
            [appDelegate referCall:[textNumber text]];
        }
            break;
        case kTAGMute:
        {
            UIButton* buttonMute = (UIButton*)sender;
            if([[[buttonMute titleLabel] text] isEqualToString:@"unMute"])
            {
                [appDelegate muteCall:FALSE];
                
                [buttonMute setTitle:@"Mute" forState: UIControlStateNormal];
                [labelStatus setText:@"Mute"];
            }
            else
            {
                [appDelegate muteCall:TRUE];
                
                [buttonMute setTitle:@"unMute" forState: UIControlStateNormal];
                [labelStatus setText:@"unMute"];
            }
            break;
        }
        case kTAGSpeak:
        {
            UIButton* buttonSpeaker = (UIButton*)sender;
            if([[[buttonSpeaker titleLabel] text] isEqualToString:@"Speaker"])
            {
                [appDelegate setLoudspeakerStatus:true];
                
                [buttonSpeaker setTitle:@"earphone" forState: UIControlStateNormal];
                [labelStatus setText:@"Enable Speaker"];
            }
            else
            {
                [appDelegate setLoudspeakerStatus:false];
                
                [buttonSpeaker setTitle:@"Speaker" forState: UIControlStateNormal];
                [labelStatus setText:@"Disable Speaker"];
            }
        }
            break;
	}
}

- (IBAction) onLineClick: (id)sender
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate switchSessionLine];
}

- (void) setStatusText:(NSString*)statusText
{
   [labelStatus setText:statusText];
    NSLog(@"%@",statusText);
}
@end
