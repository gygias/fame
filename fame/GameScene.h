//
//  GameScene.h
//  fame
//

//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Bouncer, Celeb;

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property SKNode *parentNode;
@property SKNode *streetNode;
@property SKNode *cityNode;
@property Bouncer *bouncer;
@property Celeb *celeb;

// io events
@property CGPoint firstTapLocation;
@property NSDate *lastTapDate;

// locking movement
@property CGFloat foregroundXMovement;
@property NSTimeInterval foregroundXMovementTime;

// combo
@property NSDate *lastKillDate;
@property NSUInteger currentCombo;
@property NSUInteger comboMultiplier;

// info panel
@property SKSpriteNode *infoPanelNode;
@property SKLabelNode *labelNode;

@end
