//
//  Meter.m
//  fame
//
//  Created by david on 8/13/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Meter.h"

#import "Fame.h"

@implementation Meter

NSString *MeterBorderNameBase = @"meter-border-";
NSString *MeterFillerNameBase = @"meter-filler-";

+ (CGSize)meterSize
{
    NSString *textureName = [NSString stringWithFormat:@"%@1",MeterBorderNameBase];
    Meter *meter = [Meter spriteNodeWithImageNamed:textureName];
    meter.texture.filteringMode = SKTextureFilteringNearest;
    meter.name = @"meter-border";
    meter.zPosition = CONTROL_PANEL_BACKGROUND_Z;
    meter.xScale = METER_X_SCALE; // XXX
    meter.yScale = METER_Y_SCALE;
    
    return meter.size;
}

+ (Meter *)meterWithLabel:(NSString *)label textureNumber:(int)textureNumber origin:(CGPoint)origin xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset centered:(BOOL)centered
{
    NSString *textureName = [NSString stringWithFormat:@"%@1",MeterBorderNameBase];
    Meter *meter = [Meter spriteNodeWithImageNamed:textureName];
    meter.texture.filteringMode = SKTextureFilteringNearest;
    meter.name = @"meter-border";
    meter.zPosition = CONTROL_PANEL_BACKGROUND_Z;
    meter.xScale = METER_X_SCALE; // XXX
    meter.yScale = METER_Y_SCALE;
    meter.position = CGPointMake(origin.x + xOffset + meter.size.width, origin.y + 1 + yOffset);
    //meter1Border.yScale = ( backgroundSprite.size.height ) / ( ( meter1Border.texture.size.height - 1 ) / 2 );
    
    SKLabelNode *backLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    backLabelNode.name = @"meter-back-label";
    backLabelNode.position = CGPointMake( 0, -2.0 );
    backLabelNode.zPosition = CONTROL_PANEL_CONTENT_Z;
    backLabelNode.fontSize = METER_LABEL_FONT_SIZE;
    backLabelNode.fontColor = [UIColor whiteColor];
    backLabelNode.userData = [NSMutableDictionary dictionary];
    backLabelNode.text = label;
    backLabelNode.xScale = 1 / METER_X_SCALE;
    backLabelNode.yScale = 1 / METER_Y_SCALE;
    [meter addChild:backLabelNode];
    
    NSString *fillerTextureName = [NSString stringWithFormat:@"%@%d",MeterFillerNameBase,textureNumber];
    SKSpriteNode *fillerNode = [SKSpriteNode spriteNodeWithImageNamed:fillerTextureName];
    fillerNode.texture.filteringMode = SKTextureFilteringNearest;
    fillerNode.name = @"meter-filler";
    fillerNode.xScale = METER_FILLER_MIN_SCALE / METER_X_SCALE;
    fillerNode.yScale = METER_FILLER_Y_SCALE / METER_Y_SCALE;
    fillerNode.position = centered ? CGPointMake(0,0) : CGPointMake( -4.8, 0 );
    fillerNode.zPosition = CONTROL_PANEL_CD_Z;
    meter.fillerNode = fillerNode;
    [meter addChild:fillerNode];
    
    SKLabelNode *frontLabelNode = [backLabelNode copy];
    frontLabelNode.name = @"meter-front-label";
    //backLabelNode.position = backLabelNode.position;
    frontLabelNode.zPosition = CONTROL_PANEL_CD_Z;
    //backLabelNode.fontSize = backLabelNode.fontSize;
    frontLabelNode.fontColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    //backLabelNode.userData = [NSMutableDictionary dictionary];
    //backLabelNode.text = @"anger";
    [meter addChild:frontLabelNode];
    
    meter.centered = centered;
    
    return meter;
}

@end
