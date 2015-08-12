//
//  EntityNode.h
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SpriteKit/SpriteKit.h>

#import "GameScreenMap.h"

@interface EntityNode : SKSpriteNode

@property BOOL rightToLeft;

@property BOOL isFriendly;
@property BOOL isAirborne;
@property BOOL isDead;
#warning do this
@property (nonatomic) BOOL isFrightened;
@property BOOL isMidAction;
@property BOOL currentActionIsInterruptible;

// overrides
- (void)introduceWithFrame:(CGRect)frame screenMap:(GameScreenMap *)screenMap;
- (NSString *)introSoundName;
- (NSString *)frightenedSoundName;
- (NSString *)deathSoundName;

@end
