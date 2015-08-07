//
//  GameScene.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
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
    
    NSArray *foregroundTextureNames = @[ @"road1", @"street1", @"background1" ];
    for ( NSString *textureName in foregroundTextureNames )
        [self _addForegroundTextureToNode:cityscape named:textureName];
}

static CGFloat gLastYOffset = 0; // XXX
- (void)_addForegroundTextureToNode:(SKNode *)node named:(NSString *)imageName
{
    SKTexture *texture = [SKTexture textureWithImageNamed:imageName];
    texture.filteringMode = SKTextureFilteringNearest; // antialiasing?
    
    BOOL isHills = [imageName isEqualToString:@"background1"];
    
    double speedScalar = isHills ? 0.08 : 0.02;
    
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
        CGFloat yOffset = gLastYOffset;
        if ( isHills )
            yOffset = 350;
        
        [sprite setPosition:CGPointMake(i * sprite.size.width, yOffset + spriteHeight)];
        [sprite runAction:repeatForever];
        
        if ( isHills )
            sprite.zPosition = 1.0;
        else
            sprite.zPosition = 2.0;
            
        [node addChild:sprite];
    }
    gLastYOffset += spriteHeight * 2;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
