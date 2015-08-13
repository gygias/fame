//
//  MyPanGestureRecognizer.h
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPanGestureRecognizer : UIPanGestureRecognizer
{
    CGPoint _currentStartPoint;
}

@property (readonly) CGPoint currentStartPoint;

@end
