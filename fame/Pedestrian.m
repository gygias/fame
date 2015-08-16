//
//  Pedestrian.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Pedestrian.h"

#import "Fame.h"

extern CGFloat gControlPanelHeight;

@implementation Pedestrian

- (id)init
{
    if ( ( self = [self initWithImageNamed:@"pedestrian-1"] ) )
    {
    }
    return self;
}

- (BOOL)introduceWithScreenMap:(GameScreenMap *)screenMap
{
    CGFloat textureWidth = self.texture.size.width;
    CGFloat textureHeight = self.texture.size.height;
    CGFloat stageRight = screenMap.screenRect.origin.x + screenMap.screenRect.size.width + textureWidth;
    CGFloat stageLeft = screenMap.screenRect.origin.x - textureWidth;
    
    self.rightToLeft = ( arc4random() % 2 ) == 0;
    
    if ( self.rightToLeft )
        self.xScale = ( self.xScale * -1.0 );
    
    BOOL upperOrLower = ( arc4random() % 2 ) == 0;
    double div = (double)(arc4random() % 100 + 1) / 100.0;
    CGFloat randomY = screenMap.screenRect.origin.y +
                            ( upperOrLower ? ( screenMap.topSidewalkLower + div * screenMap.topSidewalkHeight + textureHeight / 2 ) :
                                                ( screenMap.bottomSidewalkLower + div * screenMap.bottomSidewalkHeight + textureHeight / 2 ) );
    //NSLog(@"ped @ %0.2f ( %0.2f :: %0.2f-%0.2f & %0.2f - %0.2f )",randomY, gControlPanelHeight, BOTTOM_SIDEWALK_LOWER, BOTTOM_SIDEWALK_UPPER, TOP_SIDEWALK_LOWER, TOP_SIDEWALK_UPPER);
    self.position = CGPointMake( self.rightToLeft ? stageRight : stageLeft,
                                        randomY );
    double speedScalar = (double)(arc4random() % 10);
    
    SKAction *movement = [SKAction moveToX:self.rightToLeft ? stageLeft : stageRight duration:speedScalar];
    
    CGFloat stepTime = speedScalar / 15;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, stepTime * NSEC_PER_SEC, stepTime * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        //SKAction *flipAction = [SKAction scaleXTo:-(sprite.xScale) duration:0];
        self.xScale = -(self.xScale);
        //[sprite runAction:flipAction];
    });
    dispatch_resume(timer);
    
    self.actionDispatchSources = @[ timer ];
    
    [self runAction:movement completion:^{
        [self removeFromParent];
        [self.userData removeObjectForKey:@"stepTimer"];
    }];
    
    return YES;
}

@end
