//
//  SecondViewController.h
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumpadViewController : UIViewController<UITextFieldDelegate>{

}

@property (retain, nonatomic) IBOutlet UITextField *textNumber;//拨号显示textField
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;//拨号状态显示label
@property (retain, nonatomic) IBOutlet UIButton *buttonLine;//line选择按钮

- (IBAction) onButtonClick: (id)sender;//拨号盘数字按钮点击事件
- (IBAction) onLineClick: (id)sender;//线路line选择按钮事件

- (void) setStatusText:(NSString*)statusText;//设置拨号状态显示label方法
@end
