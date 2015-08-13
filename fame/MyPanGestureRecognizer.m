//
//  MyPanGestureRecognizer.m
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MyPanGestureRecognizer.h"

// XXX i have a feeling this will fail review
@interface UIPanGestureRecognizer (CombobulatedExtensions)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@implementation MyPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    _currentStartPoint = [touches.anyObject locationInView:self.view];
}

- (CGPoint)currentStartPoint
{
    return _currentStartPoint;
}

- (void)reset
{
    _currentStartPoint = CGPointMake(NAN,NAN);
}

@end
