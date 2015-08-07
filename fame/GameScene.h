//
//  GameScene.h
//  fame
//

//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property SKNode *parentNode;
@property SKNode *playerNode;
@property SKNode *celebNode;
@property CGPoint firstTapLocation;
@property NSDate *lastTapDate;

@end
