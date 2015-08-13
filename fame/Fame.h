//
//  Fame.h
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScreenMap.h"
#import "Bouncer.h"
#import "Celeb.h"
#import "Pedestrian.h"
#import "Skater.h"
#import "Taxi.h"

#import "Utility.h"

#define FOREGROUND_SPEED 0.02
#define FOREGROUND_Z 2.0

#define BACKGROUND_SPEED 0.10
#define BACKGROUND_Z 1.0

#define EFFECT_Z 2.0
#define ENTITY_Z 3.0
#define ENTITY_Z_MAX 4.0
#define INFO_PANEL_Z 4.1
#define INFO_PANEL_CONTENT_Z 4.2

#define CONTROL_PANEL_FRAME_Z 5.4
#define CONTROL_PANEL_CD_Z 5.3
#define CONTROL_PANEL_CONTENT_Z 5.2
#define CONTROL_PANEL_BACKGROUND_Z 5.1
#define CONTROL_PANEL_Z 5.0

#define STANDARD_MOVE_DURATION 0.5
#define VELOCITY_THRESHOLD 50.0

#define FLYAWAY_Y 650
#define FLYAWAY_X 500
#define FLYAWAY_POINT ( CGPointMake( FLYAWAY_X, FLYAWAY_Y ) )

#define MOVE_CD 1.0
#define JUMP_HEIGHT 150.0
#define EARTHQUAKE_RADIUS 150.0
#define EARTHQUAKE_GROUND_EFFECT_RADIUS 100.0
#define EARTHQUAKE_CD 5.0

typedef enum : uint8_t {
    ColliderEntity                  = 1,
    ColliderBouncer                 = 2,
    ColliderCeleb                   = 4,
    ColliderAI                      = 8,
    ColliderProjectile              = 16,
    ColliderGroundEffect            = 32,
    ColliderWall                    = 64
} ColliderType;

