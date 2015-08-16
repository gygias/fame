//
//  Sound.h
//  fame
//
//  Created by david on 8/15/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Sound : NSObject

+ (void)setScene:(SKScene *)scene;

+ (void)playSoundNamed:(NSString *)soundName onNode:(SKNode *)node;
+ (NSObject *)playStoppableSoundNamed:(NSString *)soundName onNode:(SKNode *)node;
+ (void)stopSound:(NSObject *)sound;

+ (NSString *)randomSlotSpin;
+ (NSString *)randomBoom;
+ (NSString *)randomGrunt:(BOOL)male;
+ (NSString *)randomScream:(BOOL)male;

@end

@interface NSObject (ImplementsStop)
- (void)stop;
@end