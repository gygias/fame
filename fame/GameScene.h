//
//  GameScene.h
//  fame
//

//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "Fame.h"

@class Bouncer, Celeb, MyPanGestureRecognizer;

@interface GameScene : SKScene <SKPhysicsContactDelegate>
{
    MyPanGestureRecognizer *_panRecognizer;
}

@property GameScreenMap *gameScreenMap;

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

// combo panel
@property ComboBox *comboBoxNode;

// control panel
@property SKSpriteNode *controlPanel;
@property SKSpriteNode *button1;
@property SKSpriteNode *button2;
@property SKSpriteNode *button3;
@property SKSpriteNode *button4;

@property Meter *meter1;
@property Meter *meter2;

@end
