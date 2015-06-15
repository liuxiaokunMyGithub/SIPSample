//
//  SecondViewController.h
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumpadViewController : UIViewController<UITextFieldDelegate>{
@public
    UILabel     *labelStatus;

    
@protected
    UITextField *textNumber;
}

@property (retain, nonatomic) IBOutlet UITextField *textNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIButton *buttonLine;

- (IBAction) onButtonClick: (id)sender;
- (IBAction) onLineClick: (id)sender;

- (void) setStatusText:(NSString*)statusText;
@end
