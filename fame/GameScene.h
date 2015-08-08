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
@property CGPoint firstTapLocation;
@property NSDate *lastTapDate;
@property CGFloat foregroundXMovement;
@property NSTimeInterval foregroundXMovementTime;

@end
