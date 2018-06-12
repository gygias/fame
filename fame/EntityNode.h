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

@property BOOL isUI; // XXX seperate inheritances?

@property BOOL rightToLeft;
@property (readonly) CGSize collisionSize;

@property BOOL isFriendly;
@property BOOL isIncapacitated;
@property BOOL isFloored;
@property BOOL isAirborne;
@property BOOL isDead;
@property BOOL isManualZ; // don't automatically set zPos on update: (flyaway, etc)
@property (nonatomic) BOOL isFrightened;
@property BOOL isMidAction;
@property BOOL currentActionIsInterruptible;
@property NSArray *actionDispatchSources;

@property NSUInteger impactChain;

- (id)initWithImageNamed:(NSString *)name withPhysics:(BOOL)withPhysics;
- (void)dispatchActionPause;
- (void)dispatchActionResume;

// super overrides
- (void)runAction:(SKAction *)action withKey:(NSString *)key completion:(void (^)(void))block;

// subclass overrides
- (BOOL)introduceWithScreenMap:(GameScreenMap *)screenMap;
- (NSArray *)introSoundNames;
- (NSArray *)frightenedSoundNames;
- (NSArray *)deathSoundNames;

@end

@interface SKNode (CombobulatedExtensions)

- (CGPoint)midpointToNode:(SKNode *)node;
- (void)removeChildrenNamed:(NSString *)childName;

@end
