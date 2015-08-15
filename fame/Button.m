//
//  Button.m
//  fame
//
//  Created by david on 8/13/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Button.h"

#import "Fame.h"

@implementation Button

+ (Button *)buttonWithName:(NSString *)name origin:(CGPoint)origin xOffset:(CGFloat)xOffset
{
    SKTexture *frameTexture = [SKTexture textureWithImageNamed:@"button-frame-1"];
    frameTexture.filteringMode = SKTextureFilteringNearest;
    SKTexture *buttonBackgroundTexture = [SKTexture textureWithImageNamed:@"button-background-1"];
    buttonBackgroundTexture.filteringMode = SKTextureFilteringNearest;
    
    Button *button = [Button spriteNodeWithTexture:buttonBackgroundTexture];
    button.name = @"background";
    button.zPosition = CONTROL_PANEL_BACKGROUND_Z;
    button.position = CGPointMake(origin.x + xOffset, origin.y + 1);
    button.scale = 0.45;
    button.userData = [NSMutableDictionary dictionary];
    
    SKTexture *buttonContentTexture = [SKTexture textureWithImageNamed:name];
    buttonContentTexture.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode *buttonContentNode = [SKSpriteNode spriteNodeWithTexture:buttonContentTexture];
    buttonContentNode.name = @"content";
    buttonContentNode.zPosition = CONTROL_PANEL_CONTENT_Z;
    buttonContentNode.position = CGPointMake(0,0);//CGPointMake(fuckingBottomLeft.x + xOffset, fuckingBottomLeft.y + 1);
    //buttonContentNode.scale = 0.45 * scale;
    [button addChild:buttonContentNode];
    
    SKSpriteNode *buttonFrameSprite = [SKSpriteNode spriteNodeWithTexture:frameTexture];
    buttonFrameSprite.name = @"frame";
    buttonFrameSprite.zPosition = CONTROL_PANEL_FRAME_Z;
    buttonFrameSprite.position = CGPointMake(0,0);//CGPointMake(fuckingBottomLeft.x + xOffset - magicalMysteryNumber/2, fuckingBottomLeft.y + 1);
    //buttonFrameSprite.scale = 0.45 * scale;
    buttonFrameSprite.userData = [NSMutableDictionary dictionary];
    [button addChild:buttonFrameSprite];
    
    return button;
}

@end
