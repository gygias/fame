//
//  Skater.m
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Skater.h"

@implementation Skater

- (id)init
{
    if ( ( self = [self initWithImageNamed:@"skater-1"] ) )
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
        [self setScale:1.5];
    }
    return self;
}

#define SKATER_MAX_POINTS 3

- (void)introduceWithFrame:(CGRect)frame screenMap:(GameScreenMap *)screenMap
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    self.rightToLeft = ( arc4random() % 2 ) == 0;
    
    if ( self.rightToLeft )
        self.xScale = ( self.xScale * -1.0 );
    
    CGFloat stageRight = ( screenMap.screenRect.origin.x + screenMap.screenRect.size.width + self.texture.size.width );
    CGFloat stageLeft = ( screenMap.screenRect.origin.x - self.texture.size.width );
    CGFloat startX = self.rightToLeft ? stageRight : stageLeft;
    CGFloat endX = self.rightToLeft ? stageLeft : stageRight;
    CGFloat randomY = (double)( arc4random() % 100 ) / 100.0 * ( screenMap.topSidewalkUpper - screenMap.bottomSidewalkLower ) + screenMap.bottomSidewalkLower;
    CGPoint startPoint = CGPointMake(startX, randomY);
    CGPoint endPoint = CGPointMake(endX, randomY);
    [path moveToPoint:startPoint];
    
    int idx, nPoints = ( arc4random() % ( SKATER_MAX_POINTS + 1 ) ) + 1 ;
    for ( idx = 0; idx < nPoints; idx++ )
    {
        CGPoint thisEndpoint;
        if ( idx == ( nPoints - 1 ) )
            thisEndpoint = endPoint;
        else
        {
            CGFloat x = (double)( arc4random() % 100 ) / 100.0 * ( screenMap.streetRight - screenMap.streetLeft );
            CGFloat y = (double)( arc4random() % 100 ) / 100.0 * ( screenMap.streetUpper - screenMap.streetLower );
            thisEndpoint = CGPointMake(x,y);
        }
        CGFloat randomControlPoint1X = (double)( arc4random() % 100 ) / 100.0 * ( screenMap.screenRect.size.width ) + screenMap.screenRect.origin.x;
        CGFloat randomControlPoint1Y = (double)( arc4random() % 100 ) / 100.0  * ( screenMap.groundHeight ) + screenMap.bottomSidewalkLower;
        CGFloat randomControlPoint2X = (double)( arc4random() % 100 ) / 100.0  * ( screenMap.screenRect.size.width ) + screenMap.screenRect.origin.x;
        CGFloat randomControlPoint2Y = (double)( arc4random() % 100 ) / 100.0  * ( screenMap.groundHeight ) + screenMap.bottomSidewalkLower;
        [path addCurveToPoint:thisEndpoint
                controlPoint1:CGPointMake(randomControlPoint1X, randomControlPoint1Y)
                controlPoint2:CGPointMake(randomControlPoint2X, randomControlPoint2Y)];
    }
    
    NSTimeInterval duration = 8;
    SKAction *move = [SKAction followPath:path.CGPath asOffset:NO orientToPath:NO duration:duration];
    
    SKAction *animate = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        BOOL shouldAnimate = ( arc4random() % ( _isManual ? 10 : 20 ) ) == 0;
        if ( shouldAnimate )
        {
            NSString *textureName = _isManual ? @"skater-1" : @"skater-2";
            SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
            texture.filteringMode = SKTextureFilteringNearest;
            [self setTexture:texture];
            _isManual = !_isManual;
        }
    }];
    
    SKAction *moveAndManual = [SKAction group:@[move,animate]];
    [self runAction:moveAndManual completion:^{
        [self removeFromParent];
    }];
    
    _path = path;
}

@end
