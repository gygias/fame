//
//  Taxi.m
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Taxi.h"

@implementation Taxi

- (id)init
{
    if ( ( self = [self initWithImageNamed:@"taxi-1"] ) )
    {
    }
    return self;
}

- (id)initWithImageNamed:(NSString *)name
{
    if ( ( self = [super initWithImageNamed:name] ))
    {
        // skater only?
        //self.physicsBody.allowsRotation = NO;
        [self setScale:3.0];
    }
    return self;
}

- (void)introduceWithFrame:(CGRect)frame screenMap:(GameScreenMap *)screenMap
{
    self.rightToLeft = ( arc4random() % 2 ) == 0;
    
    if ( self.rightToLeft )
        self.xScale = ( self.xScale * -1.0 );
    
    CGFloat stageRight = ( screenMap.screenRect.origin.x + screenMap.screenRect.size.width + self.texture.size.width );
    CGFloat stageLeft = ( screenMap.screenRect.origin.x - self.texture.size.width );
    CGFloat startX = self.rightToLeft ? stageRight : stageLeft;
    CGFloat endX = self.rightToLeft ? stageLeft : stageRight;
    
    int nLanes = 4;
    int lane = ( arc4random() % nLanes );
    
    NSString *keyString = [NSString stringWithFormat:@"lane%dOccupied",lane];
    if ( [[screenMap valueForKey:keyString] boolValue] )
    {
        [self removeFromParent];
        return;
    }
    
    CGFloat y = ((double)lane / (double)nLanes) * screenMap.streetHeight + screenMap.streetLower + self.texture.size.height * 2;
    self.position = CGPointMake(startX,y);
    
    SKAction *move = [SKAction moveToX:endX duration:self.rightToLeft ? 8 : 6];
    
    NSArray *textureNames = @[ @"taxi-1", @"taxi-2", @"taxi-3", @"taxi-4", @"taxi-5" ];
    NSMutableArray *textures = [NSMutableArray new];
    [textureNames enumerateObjectsUsingBlock:^(NSString *textureName, NSUInteger idx, BOOL *stop) {
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        texture.filteringMode = SKTextureFilteringNearest;
        [textures addObject:texture];
    }];
    SKAction *animate = [SKAction animateWithTextures:textures timePerFrame:0.5];
    SKAction *animateForever = [SKAction repeatActionForever:animate];
    SKAction *moveAndAnimate = [SKAction group:@[ move, animateForever ]];
    
    [screenMap setValue:[NSNumber numberWithBool:YES] forKey:keyString];
    [self runAction:moveAndAnimate completion:^{
        [screenMap setValue:[NSNumber numberWithBool:NO] forKey:keyString];
        [self removeFromParent];
    }];
}

@end
