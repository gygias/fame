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
#define EFFECT_Z 2.0
#define INFO_PANEL_Z 4.0
#define INFO_PANEL_CONTENT_Z 4.1

#define CONTROL_PANEL_FRAME_Z 5.4
#define CONTROL_PANEL_CD_Z 5.3
#define CONTROL_PANEL_CONTENT_Z 5.2
#define CONTROL_PANEL_BACKGROUND_Z 5.1
#define CONTROL_PANEL_Z 5.0

#define STANDARD_MOVE_DURATION 0.5
#define VELOCITY_THRESHOLD 50.0

static CGFloat gControlPanelHeight = 0;
#define BOTTOM_SIDEWALK_LOWER gControlPanelHeight
#define BOTTOM_SIDEWALK_UPPER ( BOTTOM_SIDEWALK_LOWER + 40.0 )
#define BOTTOM_SIDEWALK_HEIGHT ( BOTTOM_SIDEWALK_UPPER - BOTTOM_SIDEWALK_LOWER )
#define TOP_SIDEWALK_LOWER ( BOTTOM_SIDEWALK_UPPER + 297 )
#define TOP_SIDEWALK_UPPER ( TOP_SIDEWALK_LOWER + 60.0 )
#define TOP_SIDEWALK_HEIGHT ( TOP_SIDEWALK_UPPER - TOP_SIDEWALK_LOWER )

#define FLYAWAY_Y 650
#define FLYAWAY_X 500
#define FLYAWAY_POINT ( CGPointMake( FLYAWAY_X, FLYAWAY_Y ) )

#define JUMP_HEIGHT 150.0
#define EARTHQUAKE_RADIUS 150.0
#define EARTHQUAKE_GROUND_EFFECT_RADIUS 100.0

typedef enum : uint8_t {
    ColliderEntity                  = 1,
    ColliderBouncer                 = 2,
    ColliderCeleb                   = 4,
    ColliderAI                      = 8,
    ColliderProjectile              = 16,
    ColliderGroundEffect            = 32,
    ColliderWall                    = 64
} ColliderType;

#endif
