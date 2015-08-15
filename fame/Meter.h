//
//  Meter.h
//  fame
//
//  Created by david on 8/13/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Meter : SKSpriteNode

+ (Meter *)meterWithLabel:(NSString *)label origin:(CGPoint)origin xOffset:(CGFloat)xOffset;

@property SKSpriteNode *fillerNode;

@end
