//
//  Bouncer.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Bouncer.h"

#import "Fame.h"

@implementation Bouncer

- (id)init
{
    if ( self = [super _initWithTextureName:@"bouncer-1" scale:2.0] )
    {
    }
    
    return self;
}

- (uint8_t)_collisionMask
{
    return ColliderBouncer;
}

- (uint8_t)_collisionTestMask
{
    return /*ColliderBouncer |*/ ColliderCeleb | ColliderAI | ColliderProjectile | ColliderWall;
}

@end
