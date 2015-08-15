//
//  Button.h
//  fame
//
//  Created by david on 8/13/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Button : SKSpriteNode

+ (Button *)buttonWithName:(NSString *)name origin:(CGPoint)origin xOffset:(CGFloat)xOffset;

@end
