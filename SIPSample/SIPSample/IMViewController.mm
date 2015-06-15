//
//  IMViewController.m
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "IMViewController.h"
#import "ContactCell.h"
#import "AppDelegate.h"

@interface IMViewController ()
@end

@implementation IMViewController
@synthesize textContact;
@synthesize textMessage;
@synthesize contacts;
@synthesize tableView;

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
    
    textContact.delegate = self;
    textMessage.delegate = self;
	// Do any additional setup after loading the view.
    
    if(!self.contacts){
		contacts = [[NSMutableArray alloc] init];
	}
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
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

- (IBAction) onSubscribeClick: (id)sender
{
    int subscribeID = [mPortSIPSDK presenceSubscribeContact:[textContact text]  subject:@"hello"];
    
    Contact* contact = [[Contact alloc] initWithSubscribe:subscribeID andSipURL:[textContact text]];
    
    [contacts addObject:contact];
    [tableView reloadData];
}

- (IBAction) onOnlineClick: (id)sender
{
    for(int i = 0 ; i < [contacts count] ; i++)
    {
        Contact* contact = [contacts objectAtIndex: i];
        if(contact){
            [mPortSIPSDK presenceOnline:[contact subscribeID] statusText:@"I'm here"];
        }
    }
}


- (IBAction) onOfflineClick: (id)sender
{
    for(int i = 0 ; i < [contacts count] ; i++)
    {
        Contact* contact = [contacts objectAtIndex: i];
        if(contact){
            [mPortSIPSDK presenceOffline:[contact subscribeID]];
        }
    }
}

- (IBAction) onSendMessageClick: (id)sender
{
    NSData* message = [[textMessage text] dataUsingEncoding:NSUTF8StringEncoding];
    long messageID = [mPortSIPSDK sendOutOfDialogMessage:[textContact text] mimeType:@"text" subMimeType:@"plain" message:message messageLength:[message length]];

    NSLog(@"send Message %ld",messageID);
}

//Instant Message/Presence Event
-(int)onSendMessageSuccess:(long)messageId
{
    NSLog(@"%ld message send success",messageId);
    return 0;
}

-(int)onSendMessageFailure:(long)messageId reason:(char*)reason code:(int)code
{
    NSLog(@"%ld message send failure",messageId);
    return 0;
};

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    long subjectId = alertView.tag;
    if(buttonIndex == 0){//Reject Subscribe
        [mPortSIPSDK presenceRejectSubscribe:subjectId];
    }
    else if (buttonIndex == 1){//Accept Subscribe
        for(int i = 0 ; i < [contacts count] ; i++)
        {
            Contact* contact = [contacts objectAtIndex: i];
            if(contact.subscribeID == subjectId){
                [mPortSIPSDK presenceAcceptSubscribe:subjectId];
                [mPortSIPSDK presenceOnline:subjectId statusText:@"Available"];
                
                [mPortSIPSDK presenceSubscribeContact:contact.sipURL subject:@"Hello"];
            }
        }
    }
}

-(int)onPresenceRecvSubscribe:(long)subscribeId
              fromDisplayName:(char*)fromDisplayName
                         from:(char*)from
                      subject:(char*)subject
{
    for(int i = 0 ; i < [contacts count] ; i++)
    {
        Contact* contact = [contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {//has exist this contact
                //update subscribedId
                contact.subscribeID = subscribeId;
                
                //Accept subscribe.
                [mPortSIPSDK presenceAcceptSubscribe:subscribeId];
                [mPortSIPSDK presenceOnline:subscribeId statusText:@"Available"];
                return 0;
            }
        }
    }
    
    Contact* contact = [[Contact alloc] initWithSubscribe:subscribeId andSipURL:[NSString  stringWithUTF8String:from]];
    
    [contacts addObject:contact];
    [tableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Recv Subscribe"
                          message: [NSString  stringWithFormat:@"Recv Subscribe <%s>%s : %s", fromDisplayName,from,subject]
                          delegate: self
                          cancelButtonTitle: @"Reject"
                          otherButtonTitles:@"Accept", nil];
    alert.tag = subscribeId;
    [alert show];
    return 0;
}

- (void)onPresenceOnline:(char*)fromDisplayName
                    from:(char*)from
               stateText:(char*)stateText
{
    for(int i = 0 ; i < [contacts count] ; i++)
    {
        Contact* contact = [contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {
                contact.basicState = @"open";
                contact.note = [NSString stringWithUTF8String:stateText];
                [tableView reloadData];
                break;
            }
        }
    }
}

- (void)onPresenceOffline:(char*)fromDisplayName from:(char*)from
{
    for(int i = 0 ; i < [contacts count] ; i++)
    {
        Contact* contact = [contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {
                contact.basicState = @"close";
                [tableView reloadData];
                break;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0 == section){
        return [contacts count];
    }
    
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell*)[_tableView dequeueReusableCellWithIdentifier: @"ContactCellIdentifier"];
	
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    if([contacts count] > indexPath.row){
        Contact* contact = [contacts objectAtIndex: indexPath.row];
        if(contact){
            cell.urlLabel.text = contact.sipURL;
            cell.noteLabel.text = contact.note;
            if([contact.basicState isEqualToString:@"open"])
            {
                cell.onlineImageView.image = [UIImage imageNamed:@"online.png"];
            }
            else
            {
                cell.onlineImageView.image = [UIImage imageNamed:@"offline.png"];
            }
        }
    }
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Contact* contact = [contacts objectAtIndex: indexPath.row];
        if (contact) {
            //[mPortSIPSDK presenceUnsubscribeContact :contact.subscribeID];
		}
        [contacts removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
