//
//  Actor.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Actor.h"

#import "Fame.h"

@implementation Actor

- (uint8_t)_collisionMask
{
    return ColliderAI;
}

- (uint8_t)_collisionTestMask
{
    return 0xFF;
}

@end
