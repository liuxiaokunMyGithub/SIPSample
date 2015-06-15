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
    
    _textContact.delegate = self;
    _textMessage.delegate = self;
	// Do any additional setup after loading the view.
    
    if(!self.contacts){
		_contacts = [[NSMutableArray alloc] init];
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
    int subscribeID = [portSIPSDK presenceSubscribeContact:[_textContact text]  subject:@"hello"];
    
    Contact* contact = [[Contact alloc] initWithSubscribe:subscribeID andSipURL:[_textContact text]];
    
    [_contacts addObject:contact];
    [_tableView reloadData];
}

- (IBAction) onOnlineClick: (id)sender
{
    for(int i = 0 ; i < [_contacts count] ; i++)
    {
        Contact* contact = [_contacts objectAtIndex: i];
        if(contact){
            [portSIPSDK presenceOnline:[contact subscribeID] statusText:@"I'm here"];
        }
    }
}


- (IBAction) onOfflineClick: (id)sender
{
    for(int i = 0 ; i < [_contacts count] ; i++)
    {
        Contact* contact = [_contacts objectAtIndex: i];
        if(contact){
            [portSIPSDK presenceOffline:[contact subscribeID]];
        }
    }
}

- (IBAction) onSendMessageClick: (id)sender
{
    NSData* message = [[_textMessage text] dataUsingEncoding:NSUTF8StringEncoding];
    long messageID = [portSIPSDK sendOutOfDialogMessage:[_textContact text] mimeType:@"text" subMimeType:@"plain" message:message messageLength:[message length]];

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
        [portSIPSDK presenceRejectSubscribe:subjectId];
    }
    else if (buttonIndex == 1){//Accept Subscribe
        for(int i = 0 ; i < [_contacts count] ; i++)
        {
            Contact* contact = [_contacts objectAtIndex: i];
            if(contact.subscribeID == subjectId){
                [portSIPSDK presenceAcceptSubscribe:subjectId];
                [portSIPSDK presenceOnline:subjectId statusText:@"Available"];
                
                [portSIPSDK presenceSubscribeContact:contact.sipURL subject:@"Hello"];
            }
        }
    }
}

-(int)onPresenceRecvSubscribe:(long)subscribeId
              fromDisplayName:(char*)fromDisplayName
                         from:(char*)from
                      subject:(char*)subject
{
    for(int i = 0 ; i < [_contacts count] ; i++)
    {
        Contact* contact = [_contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {//has exist this contact
                //update subscribedId
                contact.subscribeID = subscribeId;
                
                //Accept subscribe.
                [portSIPSDK presenceAcceptSubscribe:subscribeId];
                [portSIPSDK presenceOnline:subscribeId statusText:@"Available"];
                return 0;
            }
        }
    }
    
    Contact* contact = [[Contact alloc] initWithSubscribe:subscribeId andSipURL:[NSString  stringWithUTF8String:from]];
    
    [_contacts addObject:contact];
    [_tableView reloadData];
    
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
    for(int i = 0 ; i < [_contacts count] ; i++)
    {
        Contact* contact = [_contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {
                contact.basicState = @"open";
                contact.note = [NSString stringWithUTF8String:stateText];
                [_tableView reloadData];
                break;
            }
        }
    }
}

- (void)onPresenceOffline:(char*)fromDisplayName from:(char*)from
{
    for(int i = 0 ; i < [_contacts count] ; i++)
    {
        Contact* contact = [_contacts objectAtIndex: i];
        if(contact){
            if([[contact sipURL] isEqualToString:[NSString stringWithUTF8String:from]])
            {
                contact.basicState = @"close";
                [_tableView reloadData];
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
        return [_contacts count];
    }
    
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier: @"ContactCellIdentifier"];
	
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    if([_contacts count] > indexPath.row){
        Contact* contact = [_contacts objectAtIndex: indexPath.row];
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Contact* contact = [_contacts objectAtIndex: indexPath.row];
        if (contact) {
            //[mPortSIPSDK presenceUnsubscribeContact :contact.subscribeID];
		}
        [_contacts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
