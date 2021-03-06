//
//  Meter.h
//  fame
//
//  Created by david on 8/13/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Meter : SKSpriteNode

+ (CGSize)meterSize;

+ (Meter *)meterWithLabel:(NSString *)label textureNumber:(int)textureNumber origin:(CGPoint)origin xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset centered:(BOOL)centered;

@property SKSpriteNode *fillerNode;
@property BOOL centered;

@end
