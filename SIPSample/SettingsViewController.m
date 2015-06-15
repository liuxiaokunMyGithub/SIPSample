//
//  SettingsViewController.m
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingCell.h"

#define kNumbersOfSections  3

static NSString *kAudioCodecsKey = @"Audio Codecs";
static NSString *kVideoCodecsKey = @"Video Codecs";
static NSString *kAudiosFeatureKey = @"Audio Feature";

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    settingsAudioCodec = [NSMutableArray arrayWithCapacity:20];
    
	SettingItem *item = [[SettingItem alloc] init];
    item.index = 0;
	item.name = @"G.729";
    item.enable = YES;
    item.codeType = AUDIOCODEC_G729;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 1;
	item.name = @"PCMA";
    item.enable = YES;
    item.codeType = AUDIOCODEC_PCMA;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 2;
	item.name = @"PCMU";
    item.enable = YES;
    item.codeType = AUDIOCODEC_PCMU;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 4;
	item.name = @"GSM";
    item.enable = NO;
    item.codeType = AUDIOCODEC_GSM;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 5;
	item.name = @"G.722";
    item.enable = NO;
    item.codeType = AUDIOCODEC_G722;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 6;
	item.name = @"iLBC";
    item.enable = NO;
    item.codeType = AUDIOCODEC_ILBC;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 7;
	item.name = @"AMR";
    item.enable = NO;
    item.codeType = AUDIOCODEC_AMR;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 8;
	item.name = @"AMRWB";
    item.enable = NO;
    item.codeType = AUDIOCODEC_AMRWB;
    [settingsAudioCodec addObject:item];
   
    
    item = [[SettingItem alloc] init];
    item.index = 9;
	item.name = @"SpeexNB(8Khz)";
    item.enable = NO;
    item.codeType = AUDIOCODEC_SPEEX;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 10;
	item.name = @"SpeexWB(16Khz)";
    item.enable = NO;
    item.codeType = AUDIOCODEC_SPEEXWB;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 11;
	item.name = @"ISACWB(16Khz)";
    item.enable = NO;
    item.codeType = AUDIOCODEC_ISACWB;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 12;
	item.name = @"ISACSWB(32Khz)";
    item.enable = NO;
    item.codeType = AUDIOCODEC_ISACSWB;
    [settingsAudioCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 13;
	item.name = @"OPUS";
    item.enable = NO;
    item.codeType = AUDIOCODEC_OPUS;
    [settingsAudioCodec addObject:item];
    
    //Video codec item
    settingsVideoCodec = [NSMutableArray arrayWithCapacity:10];
    
    item = [[SettingItem alloc] init];
    item.index = 100;
	item.name = @"H.263";
    item.enable = NO;
    item.codeType = VIDEO_CODEC_H263;
    [settingsVideoCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 101;
	item.name = @"H.263+";
    item.enable = NO;
    item.codeType = VIDEO_CODEC_H263_1998;
    [settingsVideoCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 102;
	item.name = @"H.264";
    item.enable = YES;
    item.codeType = VIDEO_CODEC_H264;
    [settingsVideoCodec addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 103;
	item.name = @"VP8";
    item.enable = NO;
    item.codeType = VIDEO_CODEC_VP8;
    [settingsVideoCodec addObject:item];
    
    //Audio Feature
    settingsAudioFeature = [NSMutableArray arrayWithCapacity:10];
    item = [[SettingItem alloc] init];
    item.index = 200;
	item.name = @"VAD";
    item.enable = NO;
    item.codeType = -1;
    [settingsAudioFeature addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 201;
	item.name = @"AEC";
    item.enable = NO;
    item.codeType = -1;
    [settingsAudioFeature addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 202;
	item.name = @"ANS";
    item.enable = NO;
    item.codeType = -1;
    [settingsAudioFeature addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = 203;
	item.name = @"AGC";
    item.enable = NO;
    item.codeType = -1;
    [settingsAudioFeature addObject:item];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //save change
    [portSIPSDK clearAudioCodec];
    
    for (SettingItem  *item in settingsAudioCodec) {
        if(item.enable)
        {
            [portSIPSDK addAudioCodec:(AUDIOCODEC_TYPE)item.codeType];
        }
    }
    
    [portSIPSDK clearVideoCodec];
    for (SettingItem  *item in settingsVideoCodec) {
        if(item.enable)
        {
            [portSIPSDK addVideoCodec:(VIDEOCODEC_TYPE)item.codeType];
        }
    }
    for (SettingItem  *item in settingsAudioFeature) {
        switch (item.index) {
            case 200:
                [portSIPSDK enableVAD:item.enable];
                break;
            case 201:
                [portSIPSDK enableAEC:item.enable?EC_DEFAULT:EC_NONE];
                break;
            case 202:
                [portSIPSDK enableANS:item.enable?NS_DEFAULT:NS_NONE];
                break;
            case 203:
                [portSIPSDK enableAGC:item.enable?AGC_DEFAULT:AGC_NONE];
                break;
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [settingsAudioCodec count];
        case 1:
            return [settingsVideoCodec count];
        case 2:
            return [settingsAudioFeature count];
        default:
            return 0;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return kAudioCodecsKey;
        case 1:
            return kVideoCodecsKey;
        case 2:
            return kAudiosFeatureKey;
        default:
            return nil;
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = (SettingCell*)[tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    
    SettingItem *item = nil;
    switch (indexPath.section) {
        case 0:
            item = [settingsAudioCodec objectAtIndex:indexPath.row];
            break;
        case 1:
            item = [settingsVideoCodec objectAtIndex:indexPath.row];
            break;
        case 2:
            item = [settingsAudioFeature objectAtIndex:indexPath.row];
            break;
        default:
            return cell;
    }
    
    [cell SetItem:item];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
