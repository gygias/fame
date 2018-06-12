//
//  ComboBox.m
//  fame
//
//  Created by david on 8/15/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ComboBox.h"

#import "Fame.h"

@implementation ComboBox

NSString *ComboBoxLabelChildName = @"label-node";

- (id)init
{
    if ( ( self = [super initWithImageNamed:@"combo-background" withPhysics:NO] ) )
    {
        self.isUI = YES;
        self.comboDuration = COMBO_TIMEOUT;
        self.zPosition = INFO_PANEL_Z;
        self.xScale = 1.7;
        self.yScale = 1.7;
    }
    return self;
}

- (BOOL)introduceWithScreenMap:(GameScreenMap *)screenMap
{
    self.position = CGPointMake(CGRectGetMidX(screenMap.screenRect),screenMap.screenRect.size.height + INFO_PANEL_Y_OFFSET);
    //CGPointMake( self.frame.origin.x - INFO_PANEL_X_OFFSET,
    //           self.frame.origin.y + INFO_PANEL_Y_OFFSET );
    
    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    labelNode.name = ComboBoxLabelChildName;
    labelNode.position = CGPointMake(0,INFO_PANEL_CONTENT_Y_OFFSET);// INFO_PANEL_CONTENT_X_OFFSET,- INFO_PANEL_CONTENT_Y_OFFSET );
    labelNode.zPosition = INFO_PANEL_CONTENT_Z;
    labelNode.fontSize = INFO_PANEL_STANDARD_FONT_SIZE;
    labelNode.fontColor = [UIColor whiteColor];
    labelNode.userData = [NSMutableDictionary dictionary];
    [self addChild:labelNode];
    
    _endPoint = CGPointMake(CGRectGetMidX(screenMap.screenRect),CGRectGetMidY(screenMap.screenRect));
    
    return YES;
}

- (void)setCombo:(NSUInteger)combo
{
    _lastUpdate = [NSDate date];
    _combo = combo;
    
    NSString *labelText = [NSString stringWithFormat:@"combo!! %u",(unsigned)combo];
    SKLabelNode *labelNode = (SKLabelNode *)[self childNodeWithName:ComboBoxLabelChildName];
    [labelNode setText:labelText];
    
    if ( ( combo % COMBO_FLASH_THRESHOLD ) == 0 )
    {
        CGFloat currentFlashInterval = COMBO_FLASH_MAX / (float)combo / 20;
        
        if ( _flashTimer )
            dispatch_source_cancel(_flashTimer);
        
        _flashTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_flashTimer, DISPATCH_TIME_NOW, currentFlashInterval * NSEC_PER_SEC, currentFlashInterval / 2 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_flashTimer, ^{
            int colorIdx = ((NSNumber *)labelNode.userData[@"flashColorIdx"]).intValue;
            UIColor *nextColor = nil;
            switch(colorIdx)
            {
                case 0:
                    nextColor = [UIColor purpleColor];
                    break;
                case 1:
                    nextColor = [UIColor blackColor];
                    break;
                case 2:
                    nextColor = [UIColor whiteColor];
                    break;
                default:
                    NSLog(@"XXX flashColorIdx");
                    colorIdx = 0;
                    nextColor = [UIColor whiteColor];
                    break;
            }
            labelNode.fontColor = nextColor;
            labelNode.userData[@"flashColorIdx"] = @(( colorIdx + 1 ) % 3);
        });
        dispatch_resume(_flashTimer);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.comboDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( [[NSDate date] timeIntervalSinceDate:self->_lastUpdate] > COMBO_TIMEOUT )
        {
            if ( self.combo > 0 )
            {
                NSLog(@"removing combo node");
                self->_combo = 0;
                [Sound playSoundNamed:@"slot-machine-cash-out-2.wav" onNode:self];
                
                NSTimeInterval duration = 1.0;
                SKAction *fade = [SKAction fadeOutWithDuration:duration];
                SKAction *center = [SKAction moveTo:self->_endPoint duration:duration];
                SKAction *fadeAndCenter = [SKAction group:@[fade,center]];
                [self runAction:fadeAndCenter completion:^{
                    if ( self.comboEndedHandler )
                        self.comboEndedHandler(self);
                    [self removeFromParent];
                }];
            }
        }
    });
}

@end
