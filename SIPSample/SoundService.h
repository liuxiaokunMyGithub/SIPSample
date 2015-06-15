
#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#	import <AVFoundation/AVAudioPlayer.h>

@interface SoundService : NSObject{
@private
	SystemSoundID dtmfLastSoundId;
	AVAudioPlayer  *playerRingBackTone;//接通回音
	AVAudioPlayer  *playerRingTone;//呼叫音
	AVAudioPlayer  *playerEvent;
	AVAudioPlayer  *playerConn;
	AVAudioPlayer  *playerKeepAwake;
	
	BOOL speakerOn;
}

-(BOOL) setSpeakerEnabled:(BOOL)enabled;
-(BOOL) isSpeakerEnabled;
-(BOOL) playRingTone;
-(BOOL) stopRingTone;
-(BOOL) playRingBackTone;
-(BOOL) stopRingBackTone;


@end
