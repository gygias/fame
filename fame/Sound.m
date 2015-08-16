//
//  Sound.m
//  fame
//
//  Created by david on 8/15/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Sound.h"

@implementation Sound

static SKScene *sScene;

+ (void)setScene:(SKScene *)scene
{
    sScene = scene;
}

+ (void)playSoundNamed:(NSString *)soundName onNode:(SKNode *)node
{
    if ( soundName )
    {
        //dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SKAction *soundEffect = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
            NSString *key = [NSString stringWithFormat:@"sound-%@-%u",soundName,arc4random()];
            [sScene runAction:soundEffect withKey:key];
        //});
    }
}

+ (NSObject *)playStoppableSoundNamed:(NSString *)soundName onNode:(SKNode *)node
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], soundName]];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //player.numberOfLoops = 1;
    
    if (!player)
        NSLog(@"%@",[error localizedDescription]);
    else
        [player play];
    
    return player;
}

+ (void)stopSound:(NSObject *)sound
{
    [(AVAudioPlayer *)sound stop];
}

NSInteger   gMaxSlotSpin = -1;
+ (NSString *)randomSlotSpin
{
    NSString *base = @"";
    NSString *type = @"slot-machine-spin";
    NSInteger *idx = &gMaxSlotSpin;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type delimiter:@"-" numberFormat:@"%d" storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@-%u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

NSInteger   gMaxBoom = -1;
+ (NSString *)randomBoom
{
    NSString *base = @"";
    NSString *type = @"boom";
    NSInteger *idx = &gMaxBoom;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

NSInteger   gMaxMaleGrunt = -1,
gMaxFemaleGrunt = -1;
+ (NSString *)randomGrunt:(BOOL)male
{
    NSString *base = male ? @"male_" : @"female_";
    NSString *type = @"grunt";
    NSInteger *idx = male ? &gMaxMaleGrunt : &gMaxFemaleGrunt;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

// XXX GROSS
+ (void)_loadMaxSoundFileIdxWithBase:(NSString *)base type:(NSString *)type storage:(NSInteger *)storage
{
    [self _loadMaxSoundFileIdxWithBase:base type:type delimiter:@"_" numberFormat:@"%02u" storage:storage];
}

+ (void)_loadMaxSoundFileIdxWithBase:(NSString *)base type:(NSString *)type delimiter:(NSString *)delimiter numberFormat:(NSString *)numberFormat storage:(NSInteger *)storage
{
    NSInteger testIdx = 1;
    NSString *fileName = nil;
    NSString *formatString = [NSString stringWithFormat:@"%@%@%@%@",base,type,delimiter,numberFormat];
    while ( ( fileName = [NSString stringWithFormat:formatString,(unsigned)testIdx] ) &&
           [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"] )
        testIdx++;
    *storage = testIdx - 1;
}

NSInteger   gMaxMaleScream = -1,
gMaxFemaleScream = -1;
+ (NSString *)randomScream:(BOOL)male
{
    NSString *base = male ? @"male_" : @"female_";
    NSString *type = @"scream";
    NSInteger *idx = male ? &gMaxMaleScream : &gMaxFemaleScream;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

@end
