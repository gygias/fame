//
//  PoliceHeli.m
//  fame
//
//  Created by david on 8/17/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PoliceHeli.h"

#import "Fame.h"

@implementation PoliceHeli

- (id)init
{
    if ( ( self = [self initWithImageNamed:@"helicopter-1"] ) )
    {
    }
    return self;
}

- (BOOL)introduceWithScreenMap:(GameScreenMap *)screenMap
{
    CGFloat textureWidth = self.texture.size.width;
    //CGFloat textureHeight = self.texture.size.height;
    CGFloat stageRight = screenMap.screenRect.origin.x + screenMap.screenRect.size.width + textureWidth;
    CGFloat stageLeft = screenMap.screenRect.origin.x - textureWidth;
    
    self.rightToLeft = RandomBool();
    
    if ( ! self.rightToLeft )
        self.xScale = ( self.xScale * -1.0 );
    
    double div = Random0Thru1();
    CGFloat randomY = screenMap.screenRect.origin.y +
                        ( screenMap.screenRect.size.height - screenMap.minAltitude ) * div + screenMap.minAltitude;
    self.position = CGPointMake( self.rightToLeft ? stageRight : stageLeft,
                                randomY );
    
    self.isManualZ = YES;
    if ( div < 0.25 )
        self.zPosition = ENTITY_Z_MAX;
    else
        self.zPosition = BEHIND_FOREGROUND_Z;
    double oneMinusDiv = ( 1 - div );
    self.xScale = self.xScale * oneMinusDiv;
    self.yScale = self.yScale * oneMinusDiv;
    
    double speedScalar = (double)(arc4random() % 10) + 5;
    
    SKAction *movement = [SKAction moveToX:self.rightToLeft ? stageLeft : stageRight duration:speedScalar];
    
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"helicopter-1"];
    SKTexture *texture2 = [SKTexture textureWithImageNamed:@"helicopter-2"];
    NSTimeInterval timePerFrame = 0.05;
    NSUInteger animations = speedScalar / timePerFrame * 2;
    SKAction *animate = [SKAction animateWithTextures:@[ texture1, texture2 ] timePerFrame:timePerFrame];
    SKAction *repeatAnimate = [SKAction repeatAction:animate count:animations];
    
    [self runAction:movement completion:^{
        [self removeFromParent];
    }];
    [self runAction:repeatAnimate];
    return YES;
}

@end
