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
    if ( self = [super initWithImageNamed:@"bouncer-1"] )
    {
        [self setScale:2.0];
        self.isFriendly = YES;
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
