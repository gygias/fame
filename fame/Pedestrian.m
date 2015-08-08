//
//  Pedestrian.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Pedestrian.h"

#import "Fame.h"

@implementation Pedestrian

- (id)init
{
    if ( self = [super _initWithTextureName:@"pedestrian-1" scale:1.0] )
    {
    }
    
    return self;
}

- (void)introduceWithFrame:(CGRect)frame
{
    CGFloat textureWidth = self.node.texture.size.width;
    CGFloat textureHeight = self.node.texture.size.height;
    CGFloat stageRight = frame.origin.x + frame.size.width + textureWidth;
    CGFloat stageLeft = frame.origin.x - textureWidth;
    BOOL rightToLeft = ( arc4random() % 2 ) == 0;
    BOOL upperOrLower = ( arc4random() % 2 ) == 0;
    double div = (double)(arc4random() % 100 + 1) / 100.0;
    CGFloat randomY = frame.origin.y +
                            ( upperOrLower ? ( TOP_SIDEWALK_LOWER + div * TOP_SIDEWALK_HEIGHT + textureHeight / 2 ) :
                                                ( BOTTOM_SIDEWALK_LOWER + div * BOTTOM_SIDEWALK_HEIGHT + textureHeight / 2 ) );
    self.node.position = CGPointMake( rightToLeft ? stageRight : stageLeft,
                                        randomY );
    double speedScalar = (double)(arc4random() % 10);
    
    SKAction *movement = [SKAction moveToX:rightToLeft ? stageLeft : stageRight duration:speedScalar];
    [self.node runAction:movement completion:^{
        [self.node removeFromParent];
    }];
}

@end
