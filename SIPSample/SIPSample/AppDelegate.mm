//
//  AppDelegate.m
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "SoundService.h"

@interface AppDelegate ()
{
    SoundService* _mSoundService;
}
- (int)findSession:(long)sessionId;
@end

@implementation AppDelegate
@synthesize sipURL;
@synthesize mActiveLine;

- (int)findSession:(long)sessionId
{
	int index = -1;
	for (int i=LINE_BASE; i<MAX_LINES; ++i)
	{
		if (sessionId == mSessionArray[i].getSessionId())
		{
			index = i;
			break;
		}
	}
    
	return index;
}

- (void) pressNumpadButton:(char )dtmf
{
    if(mSessionArray[mActiveLine].getSessionState() == true)
    {
        [mPortSIPSDK sendDtmf:mSessionArray[mActiveLine].getSessionId() dtmfMethod:DTMF_RFC2833 code:dtmf dtmfDration:160 playDtmfTone:TRUE];
    }
}

- (void) makeCall:(NSString*) callee
        videoCall:(BOOL)videoCall
{
    if(mSessionArray[mActiveLine].getSessionState() == true ||
       mSessionArray[mActiveLine].getRecvCallState() == true)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Current line is busy now, please switch a line"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    
    long sessionId = [mPortSIPSDK call:callee sendSdp:TRUE videoCall:videoCall];
    
    if(sessionId >= 0)
    {
        mSessionArray[mActiveLine].setSessionId(sessionId);
        mSessionArray[mActiveLine].setSessionState(true);
        mSessionArray[mActiveLine].setVideoState(videoCall);
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Calling:%@ on line %ld", callee, mActiveLine]];
    }
    else
    {
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"make call failure ErrorCode =%ld", sessionId]];
    }
}

- (void) hungUpCall
{
    
    if (_isConference) {
        [self removeFromConference:mSessionArray[mActiveLine].getSessionId()];
    }
    
    if (mSessionArray[mActiveLine].getSessionState() == true)
    {
        [mPortSIPSDK hangUp :mSessionArray[mActiveLine].getSessionId()];
        if (mSessionArray[mActiveLine].getVideoState() == true) {
            [videoViewController onStopVideo:mSessionArray[mActiveLine].getSessionId()];
        }
        mSessionArray[mActiveLine].reset();
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hungup call on line %d", mActiveLine]];

    }
    else if (mSessionArray[mActiveLine].getRecvCallState() == true)
    {
        [mPortSIPSDK rejectCall:mSessionArray[mActiveLine].getSessionId() code:486];
        mSessionArray[mActiveLine].reset();
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Rejected call on line %d", mActiveLine]];
    }
    
    [self setLoudspeakerStatus:YES];
}

- (void) holdCall
{
    if (mSessionArray[mActiveLine].getSessionState() == false ||
        mSessionArray[mActiveLine].getHoldState() == true)
    {
        return;
    }
    
    [mPortSIPSDK hold:mSessionArray[mActiveLine].getSessionId()];
    mSessionArray[mActiveLine].setHoldState(true);
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hold the call on line %ld", (long)mActiveLine]];
    
    if (_isConference) {
        [self holdAllCall];
    }
}

- (void) unholdCall
{
    if (mSessionArray[mActiveLine].getSessionState() == false ||
        mSessionArray[mActiveLine].getHoldState() == false)
    {
        return;
    }
    
    [mPortSIPSDK unHold:mSessionArray[mActiveLine].getSessionId()];
    mSessionArray[mActiveLine].setHoldState(false);
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"UnHold the call on line %ld", (long)mActiveLine]];
    
    if (_isConference) {
        [self unholdAllCall];
    }
}

- (void) referCall:(NSString*)referTo
{
    if (mSessionArray[mActiveLine].getSessionState() == false)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Need to make the call established first"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    int errorCodec = [mPortSIPSDK refer:mSessionArray[mActiveLine].getSessionId() referTo:referTo];
    if (errorCodec != 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Refer failed"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) muteCall:(BOOL)mute
{
    if(mSessionArray[mActiveLine].getSessionState() == true){
        if(mute)
        {
            [mPortSIPSDK muteSession:mSessionArray[mActiveLine].getSessionId()
                   muteIncomingAudio:TRUE
                   muteOutgoingAudio:TRUE
                   muteIncomingVideo:TRUE
                   muteOutgoingVideo:TRUE];
            if (_isConference) {
                [self muteAllCall];
            }
        }
        else
        {
            [mPortSIPSDK muteSession:mSessionArray[mActiveLine].getSessionId()
                   muteIncomingAudio:FALSE
                   muteOutgoingAudio:FALSE
                   muteIncomingVideo:FALSE
                   muteOutgoingVideo:FALSE];
            if (_isConference) {
                [self unMuteAllCall];
            }
        }
    }
}

- (void) setLoudspeakerStatus:(BOOL)enable
{
    [mPortSIPSDK setLoudspeakerStatus:enable];
}

- (void)didSelectLine:(NSInteger)activeLine
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

    [tabBarController dismissViewControllerAnimated:TRUE completion:nil];
    
    if (mSIPRegistered == false || mActiveLine == activeLine)
	{
		return;
	}
    
	if (mSessionArray[mActiveLine].getSessionState()==true && mSessionArray[mActiveLine].getHoldState()==false && !_isConference)
	{
		// Need to hold this line
        [mPortSIPSDK hold:mSessionArray[mActiveLine].getSessionId()];
        
		mSessionArray[mActiveLine].setHoldState(true);
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hold call on line %d", mActiveLine]];
	}
    
    mActiveLine = activeLine;
    [numpadViewController.buttonLine setTitle:[NSString  stringWithFormat:@"Line%d:", mActiveLine] forState:UIControlStateNormal];
    
	if (mSessionArray[mActiveLine].getSessionState()==true && mSessionArray[mActiveLine].getHoldState()==true && !_isConference)
	{
		// Need to unhold this line
        [mPortSIPSDK unHold:mSessionArray[mActiveLine].getSessionId()];

		mSessionArray[mActiveLine].setHoldState(false);
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"unHold call on line %d", mActiveLine]];
	}
    
}

- (void) switchSessionLine
{
    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    LineTableViewController* selectLineView  = [stryBoard instantiateViewControllerWithIdentifier:@"LineTableViewController"];
    
    selectLineView.delegate = self;
    selectLineView.mActiveLine = mActiveLine;
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    [tabBarController presentViewController:selectLineView animated:YES completion:nil];
}

//
//	sip callback events implementation
//
//Register Event
- (void)onRegisterSuccess:(char*) statusText statusCode:(int)statusCode

{
    mSIPRegistered = TRUE;
    [loginViewController onRegisterSuccess:statusCode withStatusText:statusText];
};

- (void)onRegisterFailure:(char*) statusText statusCode:(int)statusCode
{
    mSIPRegistered = FALSE;
    [loginViewController onRegisterFailure:statusCode withStatusText:statusText];
};


//Call Event
- (void)onInviteIncoming:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
{
    int index = -1;
	for (int i=0; i< MAX_LINES; ++i)
	{
		if (mSessionArray[i].getSessionState()==false && mSessionArray[i].getRecvCallState()==false)
		{
			mSessionArray[i].setRecvCallState(true);
			index = i;
			break;
		}
	}
    
	if (index == -1)
	{
        [mPortSIPSDK rejectCall:sessionId code:486];
		return ;
	}
    
	mSessionArray[index].setSessionId(sessionId);
    mSessionArray[index].setVideoState(existsVideo);
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Incoming call:%s on line %d",caller, index]];
    
    [_mSoundService playRingTone];
    
    if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        if (localNotif){
            localNotif.alertBody =[NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index];
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 1;
            // In iOS 8.0 and later, your application must register for user notifications using -[UIApplication registerUserNotificationSettings:] before being able to schedule and present UILocalNotifications
            [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
        }
    }
    
    if(existsVideo)
    {//video call
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Incoming Call"
                              message: [NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index]
                              delegate: self
                              cancelButtonTitle: @"Reject"
                              otherButtonTitles:@"Answer", @"Video",nil];
        alert.tag = index;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Incoming Call"
                              message: [NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index]
                              delegate: self
                              cancelButtonTitle: @"Reject"
                              otherButtonTitles:@"Answer", nil];
        alert.tag = index;
        [alert show];
    }
};

- (void)onInviteTrying:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}

    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call is trying on line %d",index]];
};

- (void)onInviteSessionProgress:(long)sessionId
                    audioCodecs:(char*)audioCodecs
                    videoCodecs:(char*)videoCodecs
               existsEarlyMedia:(BOOL)existsEarlyMedia
                    existsAudio:(BOOL)existsAudio
                    existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
	if (existsEarlyMedia)
	{
		// Checking does this call has video
		if (existsVideo)
		{
			// This incoming call has video
			// If more than one codecs using, then they are separated with "#",
			// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
		}
        
		if (existsAudio)
		{
			// If more than one codecs using, then they are separated with "#",
			// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
		}
	}
    
	mSessionArray[index].setExistEarlyMedia(existsEarlyMedia);
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call session progress on line %d",index]];
}

- (void)onInviteRinging:(long)sessionId
             statusText:(char*)statusText
             statusCode:(int)statusCode
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    if (!mSessionArray[index].getExistEarlyMedia())
	{
		// No early media, you must play the local WAVE file for ringing tone
        [_mSoundService playRingBackTone];
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call ringing on line %d",index]];
}

- (void)onInviteAnswered:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    // If more than one codecs using, then they are separated with "#",
	// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
	// Checking does this call has video
	if (existsVideo)
	{
        [videoViewController onStartVideo:sessionId];
	}
    
	if (existsAudio)
	{
	}
    
	mSessionArray[index].setSessionState(true);
    mSessionArray[mActiveLine].setVideoState(existsVideo);
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call Established on line  %d",index]];
    
	// If this is the refer call then need set it to normal
	if (mSessionArray[index].isReferCall())
	{
		mSessionArray[index].setReferCall(false, 0);
	}
    
    ///todo: joinConference(index);
    if (_isConference) {
        [self joinToConference:sessionId];
    }
    [_mSoundService stopRingBackTone];
}

- (void)onInviteFailure:(long)sessionId
                 reason:(char*)reason
                   code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}

    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to call on line  %d,%s(%d)",index,reason,code]];
    
	if (mSessionArray[index].isReferCall())
	{
		// Take off the origin call from HOLD if the refer call is failure
		long originIndex = -1;
		for (int i=LINE_BASE; i<MAX_LINES; ++i)
		{
			// Looking for the origin call
			if (mSessionArray[i].getSessionId() == mSessionArray[index].getOriginCallSessionId())
			{
				originIndex = i;
				break;
			}
		}
        
		if (originIndex != -1)
		{
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call failure on line  %d,%s(%d)",index,reason,code]];
            
			// Now take off the origin call
            [mPortSIPSDK unHold:mSessionArray[index].getOriginCallSessionId()];

			mSessionArray[originIndex].setHoldState(false);
            
			// Switch the currently line to origin call line
			mActiveLine = originIndex;
            
            NSLog(@"Current line is: %ld",mActiveLine);
		}
	}
    
	mSessionArray[index].reset();
    
    [_mSoundService stopRingTone];
    [_mSoundService stopRingBackTone];
    [self setLoudspeakerStatus:YES];
    
}

- (void)onInviteUpdated:(long)sessionId
            audioCodecs:(char*)audioCodecs
            videoCodecs:(char*)videoCodecs
            existsAudio:(BOOL)existsAudio
            existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
	// Checking does this call has video
	if (existsVideo)
	{
        [videoViewController onStartVideo:sessionId];
	}
	if (existsAudio)
	{
	}
    
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"The call has been updated on line %d",index]];
}

- (void)onInviteConnected:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"The call is connected on line %d",index]];
    if (mSessionArray[index].getVideoState()) {
        [self setLoudspeakerStatus:YES];
    }
    else{
        [self setLoudspeakerStatus:NO];
    }
    NSLog(@"onInviteConnected...");
}


- (void)onInviteBeginingForward:(char*)forwardTo
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call has been forward to:%s" ,forwardTo]];
}

- (void)onInviteClosed:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call closed by remote on line %d",index]];

    if (mSessionArray[index].getVideoState() == true) {
        [videoViewController onStopVideo:sessionId];
    }
    
    mSessionArray[index].reset();
    
    [_mSoundService stopRingTone];
    [_mSoundService stopRingBackTone];
    //Setting speakers for sound output (The system default behavior)
    [self setLoudspeakerStatus:YES];
    NSLog(@"onInviteClosed...");
}

- (void)onRemoteHold:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Placed on hold by remote on line %d",index]];
}

- (void)onRemoteUnHold:(long)sessionId
           audioCodecs:(char*)audioCodecs
           videoCodecs:(char*)videoCodecs
           existsAudio:(BOOL)existsAudio
           existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Take off hold by remote on line  %d",index]];
}

//Transfer Event
- (void)onReceivedRefer:(long)sessionId
                referId:(long)referId
                     to:(char*)to
                   from:(char*)from
        referSipMessage:(char*)referSipMessage
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
        [mPortSIPSDK rejectRefer:referId];
		return;
	}
    
	int referCallIndex = -1;
	for (int i=LINE_BASE; i<MAX_LINES; ++i)
	{
		if (mSessionArray[i].getSessionState()==false && mSessionArray[i].getRecvCallState()==false)
		{
			mSessionArray[i].setSessionState(true);
			referCallIndex = i;
			break;
		}
	}
    
	if (referCallIndex == -1)
	{
		[mPortSIPSDK rejectRefer:referId];
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received the refer on line %d, refer to %s",index,to]];

    //auto accept refer
    // Hold currently call after accepted the REFER
    
    [mPortSIPSDK hold:mSessionArray[mActiveLine].getSessionId()];
    mSessionArray[mActiveLine].setHoldState(true);
    
    long referSessionId = [mPortSIPSDK acceptRefer:referId referSignaling:[NSString stringWithUTF8String:referSipMessage]];
    if (referSessionId <= 0)
    {
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to accept the refer."]];

        
        mSessionArray[referCallIndex].reset();
        
        // Take off the hold
        [mPortSIPSDK unHold:mSessionArray[mActiveLine].getSessionId()];
        mSessionArray[mActiveLine].setHoldState(false);
    }
    else
    {
        mSessionArray[referCallIndex].setSessionId(referSessionId);
        mSessionArray[referCallIndex].setSessionState(true);
        mSessionArray[referCallIndex].setReferCall(true, mSessionArray[index].getSessionId());
        
        // Set the refer call to active line
        mActiveLine = referCallIndex;
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Accepted the refer, new call is trying on line %d",referCallIndex]];
        
        [self didSelectLine:mActiveLine];
    }
    

    /*if you want to reject Refer
     [mPortSIPSDK rejectRefer:referId];
     mSessionArray[referCallIndex].reset();
     [numpadViewController setStatusText:@"Rejected the the refer."];
     */
}

- (void)onReferAccepted:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Line %d, the REFER was accepted.",index]];
}

- (void)onReferRejected:(long)sessionId reason:(char*)reason code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Line %d, the REFER was rejected.",index]];
}

- (void)onTransferTrying:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer trying on line %d",index]];
}

- (void)onTransferRinging:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer ringing on line %d",index]];
}

- (void)onACTVTransferSuccess:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer succeeded on line %d",index]];
}

- (void)onACTVTransferFailure:(long)sessionId reason:(char*)reason code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to transfer on line %d",index]];
}

//Signaling Event
- (void)onReceivedSignaling:(long)sessionId message:(char*)message
{
    // This event will be fired when the SDK received a SIP message
    // you can use signaling to access the SIP message.
}

- (void)onSendingSignaling:(long)sessionId message:(char*)message
{
    // This event will be fired when the SDK sent a SIP message
    // you can use signaling to access the SIP message.
}

- (void)onWaitingVoiceMessage:(char*)messageAccount
        urgentNewMessageCount:(int)urgentNewMessageCount
        urgentOldMessageCount:(int)urgentOldMessageCount
              newMessageCount:(int)newMessageCount
              oldMessageCount:(int)oldMessageCount
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Has voice messages,%s(%d,%d,%d,%d)",messageAccount,urgentNewMessageCount,urgentOldMessageCount,newMessageCount,oldMessageCount]];
}

- (void)onWaitingFaxMessage:(char*)messageAccount
      urgentNewMessageCount:(int)urgentNewMessageCount
      urgentOldMessageCount:(int)urgentOldMessageCount
            newMessageCount:(int)newMessageCount
            oldMessageCount:(int)oldMessageCount
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Has Fax messages,%s(%d,%d,%d,%d)",messageAccount,urgentNewMessageCount,urgentOldMessageCount,newMessageCount,oldMessageCount]];
}

- (void)onRecvDtmfTone:(long)sessionId tone:(int)tone
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received DTMF tone: %d  on line %d",tone, index]];
}

- (void)onRecvOptions:(char*)optionsMessage
{
    NSLog(@"Received an OPTIONS message:%s",optionsMessage);
}

- (void)onRecvInfo:(char*)infoMessage
{
    NSLog(@"Received an INFO message:%s",infoMessage);
}

//Instant Message/Presence Event
- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(char*)fromDisplayName
                           from:(char*)from
                        subject:(char*)subject
{
    [imViewController onPresenceRecvSubscribe:subscribeId fromDisplayName:fromDisplayName from:from subject:subject];
}

- (void)onPresenceOnline:(char*)fromDisplayName
                    from:(char*)from
               stateText:(char*)stateText
{
    [imViewController onPresenceOnline:fromDisplayName from:from
                             stateText:stateText];
}


- (void)onPresenceOffline:(char*)fromDisplayName from:(char*)from
{
    [imViewController onPresenceOffline:fromDisplayName from:from];
}


- (void)onRecvMessage:(long)sessionId
             mimeType:(char*)mimeType
          subMimeType:(char*)subMimeType
          messageData:(unsigned char*)messageData
    messageDataLength:(int)messageDataLength
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received a MESSAGE message on line %d",index]];

    
    if (strcmp(mimeType,"text") == 0 && strcmp(subMimeType,"plain") == 0)
    {
        NSString* recvMessage = [NSString stringWithUTF8String:(const char*)messageData];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"recvMessage"
                              message: recvMessage
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (strcmp(mimeType,"application") == 0 && strcmp(subMimeType,"vnd.3gpp.sms") == 0)
    {
        // The messageData is binary data
    }
    else if (strcmp(mimeType,"application") == 0 && strcmp(subMimeType,"vnd.3gpp2.sms") == 0)
    {
        // The messageData is binary data
    }
}

- (void)onRecvOutOfDialogMessage:(char*)fromDisplayName
                            from:(char*)from
                   toDisplayName:(char*)toDisplayName
                              to:(char*)to
                        mimeType:(char*)mimeType
                     subMimeType:(char*)subMimeType
                     messageData:(unsigned char*)messageData
               messageDataLength:(int)messageDataLength
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received a message(out of dialog) from %s",from]];
    
    if (strcasecmp(mimeType,"text") == 0 && strcasecmp(subMimeType,"plain") == 0)
    {
        NSString* recvMessage = [NSString stringWithUTF8String:(const char*)messageData];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString  stringWithUTF8String:from]
                              message: recvMessage
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (strcasecmp(mimeType,"application") == 0 && strcasecmp(subMimeType,"vnd.3gpp.sms") == 0)
    {
        // The messageData is binary data
    }
    else if (strcasecmp(mimeType,"application") == 0 && strcasecmp(subMimeType,"vnd.3gpp2.sms") == 0)
    {
        // The messageData is binary data
    }
}

- (void)onSendMessageSuccess:(long)sessionId messageId:(long)messageId
{
    [imViewController onSendMessageSuccess:messageId];
}


- (void)onSendMessageFailure:(long)sessionId messageId:(long)messageId reason:(char*)reason code:(int)code
{
    [imViewController onSendMessageFailure:messageId reason:reason code:code];
}

- (void)onSendOutOfDialogMessageSuccess:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
{
    [imViewController onSendMessageSuccess:messageId];
}


- (void)onSendOutOfDialogMessageFailure:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
                                 reason:(char*)reason
                                   code:(int)code
{
    [imViewController onSendMessageFailure:messageId reason:reason code:code];
}

//Play file event
- (void)onPlayAudioFileFinished:(long)sessionId fileName:(char*)fileName
{
    
}

- (void)onPlayVideoFileFinished:(long)sessionId
{
    
}

//RTP/Audio/video stream callback data
- (void)onReceivedRTPPacket:(long)sessionId isAudio:(BOOL)isAudio RTPPacket:(unsigned char *)RTPPacket packetSize:(int)packetSize
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onSendingRTPPacket:(long)sessionId isAudio:(BOOL)isAudio RTPPacket:(unsigned char *)RTPPacket packetSize:(int)packetSize
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onAudioRawCallback:(long)sessionId
         audioCallbackMode:(int)audioCallbackMode
                      data:(unsigned char *)data
                dataLength:(int)dataLength
            samplingFreqHz:(int)samplingFreqHz
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onVideoRawCallback:(long)sessionId
         videoCallbackMode:(int)videoCallbackMode
                     width:(int)width
                    height:(int)height
                      data:(unsigned char *)data
                dataLength:(int)dataLength
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}


- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [_mSoundService stopRingTone];
    
    int index = alertView.tag;
    if(buttonIndex == 0){//reject Call
        [mPortSIPSDK rejectCall:mSessionArray[index].getSessionId() code:486];
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Reject Call on line %d",index]];
    }
    else if (buttonIndex == 1){//Answer Call
        int nRet = [mPortSIPSDK answerCall:mSessionArray[index].getSessionId() videoCall:FALSE];
        if(nRet == 0)
        {
            mSessionArray[index].setSessionState(TRUE);
            mSessionArray[index].setVideoState(FALSE);
            
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %d",index]];
            [self didSelectLine:index];
            
            if (_isConference) {
                [self joinToConference:mSessionArray[index].getSessionId()];
            }
        }
        else
        {
            mSessionArray[index].reset();
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %d Failed",index]];
        }
    }
    else if (buttonIndex == 2){//Answer Video Call
        int nRet = [mPortSIPSDK answerCall:mSessionArray[index].getSessionId() videoCall:TRUE];
        if(nRet == 0)
        {
            mSessionArray[index].setSessionState(TRUE);
            mSessionArray[index].setVideoState(TRUE);
            [videoViewController onStartVideo:mSessionArray[index].getSessionId()];
            
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %d",index]];
            [self didSelectLine:index];
            
            if (_isConference) {
                [self joinToConference:mSessionArray[index].getSessionId()];
            }
        }
        else
        {
            mSessionArray[index].reset();
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %d Failed",index]];
        }
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _mSoundService = [[SoundService alloc] init];
    
    mPortSIPSDK = [[PortSIPSDK alloc] init];
    mPortSIPSDK.delegate = self;
    
    mActiveLine = 0;
    mSIPRegistered = FALSE;
    
    _isConference = NO;
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
	loginViewController = [[tabBarController viewControllers] objectAtIndex:0];
    numpadViewController = [[tabBarController viewControllers] objectAtIndex:1];
    videoViewController = [[tabBarController viewControllers] objectAtIndex:2];
    imViewController = [[tabBarController viewControllers] objectAtIndex:3];
    settingsViewController = [[tabBarController viewControllers] objectAtIndex:4];

    loginViewController->mPortSIPSDK    = mPortSIPSDK;
    
    videoViewController->mPortSIPSDK    = mPortSIPSDK;
    imViewController->mPortSIPSDK       = mPortSIPSDK;
    settingsViewController->mPortSIPSDK = mPortSIPSDK;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if(mSessionArray[mActiveLine].getSessionState())
    {//video display use OpenGl ES, So Must Stop before APP enter background
        [videoViewController onStopVideo:mSessionArray[mActiveLine].getSessionId()];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [mPortSIPSDK startKeepAwake];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [mPortSIPSDK stopKeepAwake];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(mSessionArray[mActiveLine].getSessionState())
    {
        [videoViewController onStartVideo:mSessionArray[mActiveLine].getSessionId()];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)createConference:(UIView*)conferenceVideoWindow
{
    if (!_isConference) {
        int ret = [mPortSIPSDK createConference:conferenceVideoWindow videoResolution:VIDEO_CIF displayLocalVideo:YES];
        if (ret != 0) {
            NSLog(@"Create Conference fail");
            _isConference = NO;
            return NO;
        }
        
        _isConference = YES;
        
        for (int i = LINE_BASE; i < MAX_LINES; i++) {
            if (mSessionArray[i].getSessionState()) {
                if (mSessionArray[i].getHoldState()) {
                    [mPortSIPSDK unHold:mSessionArray[i].getSessionId()];
                    mSessionArray[i].setHoldState(false);
                }
                [self joinToConference:mSessionArray[i].getSessionId()];
            }
        }
        [self setConferenceVideoWindow:conferenceVideoWindow];
    }
    
    return YES;
}

- (BOOL)joinToConference:(long)sessionId
{
    if (_isConference) {
        int ret = [mPortSIPSDK joinToConference:sessionId];
        if (ret != 0) {
            NSLog(@"Join to Conference fail");
            return NO;
        }else{
            NSLog(@"Join to Conference success");
            return YES;
        }
    }
    return NO;
}

- (void)setConferenceVideoWindow:(UIView*)conferenceVideoWindow
{
    [mPortSIPSDK setConferenceVideoWindow:conferenceVideoWindow];
}

- (void)removeFromConference:(long)sessionId
{
    if (_isConference) {
        
        int ret = [mPortSIPSDK removeFromConference:sessionId];
        if (ret != 0) {
            NSLog(@"Session %ld Remove from Conference fail", sessionId);
        }else{
            NSLog(@"Session %ld Remove from Conference success", sessionId);
        }
    }
}

- (void)destoryConference:(UIView *)viewRemoteVideo
{
    if (_isConference) {
        
        for (int i = LINE_BASE; i < MAX_LINES; i++) {
            if (mSessionArray[i].getSessionState() ) {
                
                [mPortSIPSDK removeFromConference:mSessionArray[i].getSessionId()];
                
                if (i != mActiveLine) {
                    if (!mSessionArray[i].getHoldState()) {
                        [mPortSIPSDK hold:mSessionArray[i].getSessionId()];
                        mSessionArray[i].setHoldState(true);
                    }
                }
            }
        }
        
        [mPortSIPSDK destroyConference];
        _isConference = NO;
        NSLog(@"DestoryConference");
    }
}

- (void)holdAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (mSessionArray[i].getSessionState()) {
            [mPortSIPSDK hold:mSessionArray[i].getSessionId()];
            mSessionArray[i].setHoldState(true);
        }
    }
    NSLog(@"holdAllCall...");
}

- (void)unholdAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (mSessionArray[i].getSessionState()) {
            [mPortSIPSDK unHold:mSessionArray[i].getSessionId()];
            mSessionArray[i].setHoldState(false);
        }
    }
    NSLog(@"unholdAllCall...");
}

- (void)muteAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (mSessionArray[i].getSessionState()) {
            [mPortSIPSDK muteSession:mSessionArray[i].getSessionId()
                   muteIncomingAudio:TRUE
                   muteOutgoingAudio:TRUE
                   muteIncomingVideo:TRUE
                   muteOutgoingVideo:TRUE];
        }
    }
}

- (void)unMuteAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (mSessionArray[i].getSessionState()) {
            [mPortSIPSDK muteSession:mSessionArray[i].getSessionId()
                   muteIncomingAudio:FALSE
                   muteOutgoingAudio:FALSE
                   muteIncomingVideo:FALSE
                   muteOutgoingVideo:FALSE];
        }
    }
}
@end
