//
//  Skater.h
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "Fame.h"

@interface Skater : EntityNode
{
    UIBezierPath *_path;
    BOOL _isManual;
}

@end
