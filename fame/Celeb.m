//
//  Celeb.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Celeb.h"

#import "Fame.h"

@implementation Celeb

- (id)init
{
    if ( self = [super _initWithTextureName:@"celeb-2" scale:2.0] )
    {
    }
    
    return self;
}

- (uint8_t)_collisionMask
{
    return ColliderCeleb;
}

- (uint8_t)_collisionTestMask
{
    return ColliderBouncer /*| ColliderCeleb*/ | ColliderAI | ColliderProjectile | ColliderWall;
}

@end
