//
//  SettingsViewController.h
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PortSIPLib/PortSIPSDK.h>



@interface SettingsViewController : UITableViewController{
@public
    PortSIPSDK *portSIPSDK;
    
@private
    NSMutableArray *settingsAudioCodec;
    NSMutableArray *settingsVideoCodec;
    NSMutableArray *settingsAudioFeature;
}

@end
