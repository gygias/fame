//
//  Fame.h
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#ifndef fame_Fame_h
#define fame_Fame_h

#import "Bouncer.h"
#import "Celeb.h"
#import "Pedestrian.h"

#define FOREGROUND_SPEED 0.02
#define FOREGROUND_Z 2.0

#define BACKGROUND_SPEED 0.10
#define BACKGROUND_Z 1.0

#define ENTITY_Z 3.0

#define MOVE_SPEED 0.3
#define VELOCITY_THRESHOLD 50.0

#define TOP_SIDEWALK_UPPER 422.0
#define TOP_SIDEWALK_LOWER 400.0
#define TOP_SIDEWALK_HEIGHT ( TOP_SIDEWALK_UPPER - TOP_SIDEWALK_LOWER )
#define BOTTOM_SIDEWALK_UPPER 60.0
#define BOTTOM_SIDEWALK_LOWER 32.0
#define BOTTOM_SIDEWALK_HEIGHT ( BOTTOM_SIDEWALK_UPPER - BOTTOM_SIDEWALK_LOWER )

#define FLYAWAY_Y 650
#define FLYAWAY_X 500
#define FLYAWAY_POINT ( CGPointMake( FLYAWAY_X, FLYAWAY_Y ) )

typedef enum : uint8_t {
    ColliderEntity                  = 1,
    ColliderBouncer                 = 2,
    ColliderCeleb                   = 4,
    ColliderAI                      = 8,
    ColliderProjectile              = 16,
    ColliderWall                    = 32
} ColliderType;

#endif
