//
//  Entity.h
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SpriteKit/SpriteKit.h>

@interface Entity : NSObject

@property SKSpriteNode *node;
@property BOOL isAirborne;
@property BOOL isDead;
#warning do this
@property BOOL isFrightened;
@property BOOL isMidAction;

- (void)introduceWithFrame:(CGRect)frame;

@end

@interface Entity (Private)

- (id)_initWithTextureName:(NSString *)name;
- (id)_initWithTextureName:(NSString *)name scale:(double)scale;
//- (uint8_t)_collisionCategory;
- (uint8_t)_collisionTestMask;

@end
