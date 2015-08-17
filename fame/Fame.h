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
#import "Button.h"
#import "Meter.h"
#import "ComboBox.h"
#import "Sound.h"
#import "SpeechBubble.h"
#import "PoliceHeli.h"

#import "Utility.h"

#define GLOBAL_TIME_SCALAR 1.0

#define FOREGROUND_SPEED 0.02
#define FOREGROUND_Z 2.0
#define BEHIND_FOREGROUND_Z ( FOREGROUND_Z - 0.1 )

#define BACKGROUND_SPEED 0.10
#define BACKGROUND_Z 1.0
#define BEHIND_BACKGROUND_Z ( BACKGROUND_Z - 0.1 )
#define FRONT_BACKGROUND_Z ( BACKGROUND_Z + 0.1 )

#define EFFECT_Z 2.0
#define ENTITY_Z 3.0
#define ENTITY_Z_INC 0.01
#define ENTITY_Z_MAX 4.0
#define ENTITY_Z_SPAN ( ENTITY_Z_MAX - ENTITY_Z )
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
#define INFO_PANEL_Y_OFFSET (-55.0)
#define INFO_PANEL_CONTENT_X_OFFSET 2.0
#define INFO_PANEL_STANDARD_FONT_SIZE 10.0
#define INFO_PANEL_CONTENT_Y_OFFSET (-(INFO_PANEL_STANDARD_FONT_SIZE/2))

#define MAX_ANGER 100
#define MAX_ZEN 100
#define MOVE_ANGER 5
#define RUN_OVER_ANGER 10
#define EARTHQUAKE_ANGER (-50)
#define CHARGE_ANGER 15

#define CELEB_IMPACT_ZEN 5

#define METER_X_SCALE 15.0
#define METER_FILLER_MIN_SCALE 1.0
#define METER_FILLER_MAX_SCALE 9.9
#define METER_Y_SCALE 1.5
#define METER_FILLER_Y_SCALE 2.0
#define METER_LABEL_FONT_SIZE (8.0 * METER_Y_SCALE)

#define SPEECH_BUBBLE_FONT_SIZE 10.0

// XXX MYSTERY NUMBERS
#warning there are magical mystery numbers
#define MAGICAL_MYSTERY_FILLER_INSET 17.0
#define MAGICAL_MYSTERY_METER_LABEL_X_OFFSET 3.5
#define MAGICAL_MYSTERY_BELOW_MOUNTAINS 430.0
#define MAGICAL_MYSTERY_CLOUD_MIN_ALTITUDE 650.0
typedef enum : uint8_t {
    ColliderEntity                  = 1,
    ColliderBouncer                 = 2,
    ColliderCeleb                   = 4,
    ColliderAI                      = 8,
    ColliderProjectile              = 16,
    ColliderGroundEffect            = 32,
    ColliderWall                    = 64
} ColliderType;

