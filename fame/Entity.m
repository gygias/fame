//
//  Entity.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity.h"

#import "Fame.h"

@implementation Entity

- (void)introduceWithFrame:(CGRect)frame
{
    
}

@end

@implementation Entity (Private)

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@",[super description],self.node.name];
}

- (id)_initWithTextureName:(NSString *)name
{
    return [self _initWithTextureName:name scale:1.0];
}

- (id)_initWithTextureName:(NSString *)name scale:(double)scale
{
    SKTexture *texture = [SKTexture textureWithImageNamed:name];
    texture.filteringMode = SKTextureFilteringNearest;
    self.node = [SKSpriteNode spriteNodeWithTexture:texture];
    self.node.name = name;
    self.node.xScale = scale;
    self.node.yScale = scale;
    self.node.zPosition = ENTITY_Z;
        
    SKPhysicsBody *physics = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];//[SKPhysicsBody bodyWithTexture:texture size:texture.size];
    physics.dynamic = YES;
    physics.affectedByGravity = NO;
    physics.categoryBitMask = [self _collisionMask];
    physics.contactTestBitMask = [self _collisionTestMask];
    physics.collisionBitMask = 0;
    self.node.physicsBody = physics;
    
    self.node.userData = [NSMutableDictionary new];
    [self.node.userData setObject:self forKey:@"entity"];
    
    return self;
}

- (uint8_t)_collisionMask
{
    return ColliderEntity;
}

- (uint8_t)_collisionTestMask
{
    return 0;
}

@end
