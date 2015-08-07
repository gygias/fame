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

@end

@implementation Entity (Private)

- (id)_initWithTextureName:(NSString *)name
{
    return [self _initWithTextureName:name scale:1.0];
}

- (id)_initWithTextureName:(NSString *)name scale:(double)scale
{
    SKTexture *texture = [SKTexture textureWithImageNamed:name];    
    texture.filteringMode = SKTextureFilteringNearest;
    self.node = [SKSpriteNode spriteNodeWithTexture:texture];
    self.node.xScale = scale;
    self.node.yScale = scale;
    self.node.zPosition = ENTITY_Z;
    
    return self;
}

@end
