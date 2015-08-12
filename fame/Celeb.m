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
    if ( self = [super initWithImageNamed:@"celeb-2"] )
    {
        [self setScale:2.0];
        self.isFriendly = YES;
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
