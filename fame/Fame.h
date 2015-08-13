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

#define MOVE_CD STANDARD_MOVE_DURATION
#define JUMP_HEIGHT 150.0
#define EARTHQUAKE_RADIUS 150.0
#define EARTHQUAKE_GROUND_EFFECT_RADIUS 100.0
#define EARTHQUAKE_CD 5.0

#define CHARGE_CD 3.0

#define COMBO_TIMEOUT 3.0
#define COMBO_THRESHOLD 10
#define COMBO_FLASH_THRESHOLD 10
#define COMBO_FLASH_MAX 100
#define INFO_PANEL_X_OFFSET 20.0
#define INFO_PANEL_Y_OFFSET 40.0
#define INFO_PANEL_CONTENT_X_OFFSET 2.0
#define INFO_PANEL_CONTENT_Y_OFFSET 10.0
#define INFO_PANEL_STANDARD_FONT_SIZE 20.0

#define METER_LABEL_FONT_SIZE 8.0

#define MAX_ANGER 100
#define MOVE_ANGER 5
#define EARTHQUAKE_ANGER (-50)
#define CHARGE_ANGER 15

// XXX MYSTERY NUMBERS
#define MAGICAL_MYSTERY_FILLER_OFFSET 51.5
typedef enum : uint8_t {
    ColliderEntity                  = 1,
    ColliderBouncer                 = 2,
    ColliderCeleb                   = 4,
    ColliderAI                      = 8,
    ColliderProjectile              = 16,
    ColliderGroundEffect            = 32,
    ColliderWall                    = 64
} ColliderType;

