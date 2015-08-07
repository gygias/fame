//
//  GameScene.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScene.h"

#import "Fame.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
    
    SKNode *cityscape = [SKNode new];
    [self addChild:cityscape];
    
    [self _addWorldToNode:cityscape];
    [self _addEntitiesToNode:cityscape];
}

- (void)_addEntitiesToNode:(SKNode *)node
{
    NSArray *startEntities = @[ [Celeb class], [Bouncer class] ];
    CGFloat xOffset = 0;
    for ( Class class in startEntities )
    {
        Actor *actor = [class new];
        SKSpriteNode *sprite = actor.node;
        sprite.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset,
                                      CGRectGetMidY(self.frame));
        xOffset = -(sprite.size.width * 1.1);
        
        [node addChild:sprite];
        
        if ( [actor isKindOfClass:[Bouncer class]] )
            self.playerNode = sprite;
        else if ( [actor isKindOfClass:[Celeb class]] )
            self.celebNode = sprite;
    }
}

- (void)_addWorldToNode:(SKNode *)node
{
    NSNumber *foregroundSpeed = @( 0.02 );
    NSNumber *foregroundZ = @( FOREGROUND_Z );
    NSNumber *backgroundSpeed = @( 0.10 );
    NSNumber *backgroundZ = @( BACKGROUND_Z );
    NSArray *textureMap =           @[
                                      @{ @"name" : @"road1",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ },
                                      @{ @"name" : @"street1",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ },
                                      @{ @"name" : @"background1",
                                         @"speed" : backgroundSpeed,
                                         @"yOffset" : @( 300 ),
                                         @"zPosition" : backgroundZ }
                                      ];
    for ( NSDictionary *textureDict in textureMap )
        [self _addForegroundTextureToNode:node info:textureDict];
}

static CGFloat gLastYOffset = 0; // XXX
- (void)_addForegroundTextureToNode:(SKNode *)node info:(NSDictionary *)textureDict
{
    SKTexture *texture = [SKTexture textureWithImageNamed:textureDict[@"name"]];
    texture.filteringMode = SKTextureFilteringNearest; // antialiasing? yes
    
    double speedScalar = ((NSNumber *)textureDict[@"speed"]).doubleValue;
    
    SKAction *movement = [SKAction moveByX:(-texture.size.width * 2.0) y:0 duration:(speedScalar * texture.size.width * 2.0)];
    SKAction *resetTexture = [SKAction moveByX:(texture.size.width * 2.0) y:0 duration:0];
    SKAction *repeatForever = [SKAction repeatActionForever:[SKAction sequence:@[ movement, resetTexture ]]];
    
    CGFloat i;
    CGFloat spriteHeight = 0;
    for ( i = 0; i < 2.0 + self.frame.size.width / ( texture.size.width * 2.0 ); i++ )
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
        spriteHeight = sprite.size.height;
        [sprite setScale:2.0];
        
        // XXX
        NSNumber *yOffset = textureDict[@"yOffset"];
        if ( yOffset.doubleValue == 0 )
            yOffset = @(gLastYOffset);
        
        [sprite setPosition:CGPointMake(i * sprite.size.width, yOffset.doubleValue + spriteHeight)];
        [sprite runAction:repeatForever];
        
        sprite.zPosition = ((NSNumber *)textureDict[@"zPosition"]).doubleValue;
            
        [node addChild:sprite];
    }
    gLastYOffset += spriteHeight * 2;
}

#define TOP_OF_SIDEWALK 422.0
#define BOTTOM_OF_SIDEWALK 32.0

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
        //NSLog(@"move to %0.2f %0.2f",location.x,location.y);
        location = [self _snapLocationToSidewalk:location];
            
        SKAction *moveAction = [SKAction moveTo:location duration:MOVE_SPEED];
        [self.playerNode runAction:moveAction];
    }
}

- (CGPoint)_snapLocationToSidewalk:(CGPoint)point
{
    CGPoint snappedPoint = point;
    
    if ( snappedPoint.y > TOP_OF_SIDEWALK )
        snappedPoint.y = TOP_OF_SIDEWALK;
    else if ( snappedPoint.y < BOTTOM_OF_SIDEWALK )
        snappedPoint.y = BOTTOM_OF_SIDEWALK;
    
    return snappedPoint;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
