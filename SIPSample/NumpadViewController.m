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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textNumber.delegate = self;
    
    [_labelStatus setText:@""];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
//line显示设置
    [_buttonLine setTitle:[NSString  stringWithFormat:@"Line%u:", appDelegate.activeLine ] forState:UIControlStateNormal];
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//拨号盘数字按钮点击事件
- (IBAction) onButtonClick: (id)sender
{
    NSInteger tag = ((UIButton*)sender).tag;
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

	switch (tag) {
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
        {
			_textNumber.text = [_textNumber.text stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)tag]];
            
            char dtmf = tag;
            [appDelegate pressNumpadButton:dtmf];
        }
			break;
        case kTAGStar:
        {
			_textNumber.text = [_textNumber.text stringByAppendingString:@"*"];
            [appDelegate pressNumpadButton:10];
        }
			break;
			
		case kTAGSharp:
        {
			_textNumber.text = [_textNumber.text stringByAppendingString:@"#"];
            [appDelegate pressNumpadButton:11];
        }
			break;
        case kTAGDelete:
		{
			NSString* number = _textNumber.text;
			if([number length] >0){
                _textNumber.text = [number substringToIndex:([number length]-1)];
			}
			break;
		}
        case kTAGVideoCall:
        {
            [appDelegate makeCall:[_textNumber text] videoCall:YES];
            break;
        }
        case kTAGAudioCall:
        {
            [appDelegate makeCall:[_textNumber text] videoCall:NO];
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
            [appDelegate referCall:[_textNumber text]];
        }
            break;
        case kTAGMute:
        {//静音
            UIButton* buttonMute = (UIButton*)sender;
            if([[[buttonMute titleLabel] text] isEqualToString:@"unMute"])
            {
                [appDelegate muteCall:NO];
                
                [buttonMute setTitle:@"Mute" forState: UIControlStateNormal];
                [_labelStatus setText:@"Mute"];
            }
            else
            {
                [appDelegate muteCall:YES];
                
                [buttonMute setTitle:@"unMute" forState: UIControlStateNormal];
                [_labelStatus setText:@"unMute"];
            }
            break;
        }
        case kTAGSpeak:
        {
            UIButton* buttonSpeaker = (UIButton*)sender;
            if([[[buttonSpeaker titleLabel] text] isEqualToString:@"Speaker"])
            {
                [appDelegate setLoudspeakerStatus:YES];
                
                [buttonSpeaker setTitle:@"earphone" forState: UIControlStateNormal];
                [_labelStatus setText:@"Enable Speaker"];
            }
            else
            {
                [appDelegate setLoudspeakerStatus:NO];
                
                [buttonSpeaker setTitle:@"Speaker" forState: UIControlStateNormal];
                [_labelStatus setText:@"Disable Speaker"];
            }
        }
            break;
	}
}
//线路line选择按钮事件
- (IBAction) onLineClick: (id)sender
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate switchSessionLine];
}
//设置拨号状态显示label方法
- (void) setStatusText:(NSString *)statusText
{
   [_labelStatus setText:statusText];
    NSLog(@"%@",statusText);
}
@end
