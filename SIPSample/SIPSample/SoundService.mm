#import "SoundService.h"
#import "AppDelegate.h"

#	import <AVFoundation/AVFoundation.h>

#undef TAG
#define kTAG @"SoundService///: "
#define TAG kTAG

//
// private implementation
//
@interface SoundService(Private)
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;
@end

@implementation SoundService(Private)


+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
		
	NSError *error;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (player == nil){
	}
	
	return player;
}

@end


//
// default implementation
//
@implementation SoundService

-(SoundService*)init{
	if((self = [super init])){
		
	}
	return self;
}

-(void)dealloc{
	
	if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
#define RELEASE_PLAYER(player) \
	if(player){ \
		if(player.playing){ \
			[player stop]; \
		} \
	}
	RELEASE_PLAYER(playerKeepAwake);
	RELEASE_PLAYER(playerRingBackTone);
	RELEASE_PLAYER(playerRingTone);
	RELEASE_PLAYER(playerEvent);
	RELEASE_PLAYER(playerConn);
	
#undef RELEASE_PLAYER

}

//
// SoundService
//
-(BOOL) setSpeakerEnabled:(BOOL)enabled{
    NSString *audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
    
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory: audioSessionCategory error: &setCategoryError];
    if (!success) {
        return NO;/* handle the error in setCategoryError */
    }
    
    UInt32 doSetProperty = TRUE;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    
	UInt32 audioRouteOverride = enabled ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
	if(AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride) == 0){
		speakerOn = enabled;
		return YES;
	}
	return NO;
}

-(BOOL) isSpeakerEnabled{
	return speakerOn;
}

-(BOOL) playRingTone{
	if(!playerRingTone){
		playerRingTone = [SoundService initPlayerWithPath:@"ringtone.mp3"];
	}
	if(playerRingTone){
		playerRingTone.numberOfLoops = -1;
        [self setSpeakerEnabled:YES];
		[playerRingTone play];
		return YES;
	}
	return NO;
}

-(BOOL) stopRingTone{
	if(playerRingTone && playerRingTone.playing){
		[playerRingTone stop];
        [self setSpeakerEnabled:YES];
	}
	return YES;
}

-(BOOL) playRingBackTone{
	if(!playerRingBackTone){
		playerRingBackTone = [SoundService initPlayerWithPath:@"ringtone.mp3"];
	}
	if(playerRingBackTone){
		playerRingBackTone.numberOfLoops = -1;
        [self setSpeakerEnabled:NO];
		[playerRingBackTone play];
		return YES;
	}

	return NO;
}

-(BOOL) stopRingBackTone{
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
        [self setSpeakerEnabled:YES];
	}
	return YES;
}


static void SoundFinished(SystemSoundID soundID,void* clientData){
    AudioServicesDisposeSystemSoundID(soundID);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
