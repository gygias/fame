//
//  EntityNode.m
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EntityNode.h"

#import "Fame.h"

@implementation EntityNode

- (id)initWithImageNamed:(NSString *)name withPhysics:(BOOL)withPhysics
{
    if ( ( self = [super initWithImageNamed:name] ))
    {
        self.name = name;
        self.zPosition = ENTITY_Z;
        self.texture.filteringMode = SKTextureFilteringNearest;
        
        if ( withPhysics )
        {
            SKPhysicsBody *physics = [SKPhysicsBody bodyWithRectangleOfSize:self.texture.size];//[SKPhysicsBody bodyWithTexture:texture size:texture.size];
            physics.dynamic = YES;
            physics.affectedByGravity = NO;
            physics.categoryBitMask = [self _collisionMask];
            physics.contactTestBitMask = [self _collisionTestMask];
            physics.collisionBitMask = 0;
            
            self.physicsBody = physics;
        }
        
        self.userData = [NSMutableDictionary new];
    }
    
    return self;
}

- (id)initWithImageNamed:(NSString *)name
{
    return [self initWithImageNamed:name withPhysics:YES];
}

- (BOOL)introduceWithScreenMap:(GameScreenMap *)screenMap
{
    self.position = CGPointMake(CGRectGetMidX(screenMap.screenRect), CGRectGetMidY(screenMap.screenRect));
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.0];
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
    SKAction *fadeInAndOut = [SKAction repeatActionForever:[SKAction sequence:@[ fadeOut, fadeIn ]]];
    [self runAction:fadeInAndOut];
    
    return YES;
}

- (uint8_t)_collisionMask
{
    return ColliderAI;
}

- (uint8_t)_collisionTestMask
{
    return 0xFF;
}

- (void)setIsFrightened:(BOOL)isFrightened
{
    if ( isFrightened && ! [self actionForKey:@"frighten"] )
    {
        //NSLog(@"%@ is frightened",self.name);
        SKAction *shrink = [SKAction scaleBy:0.8 duration:1];
        [self runAction:shrink withKey:@"frighten"];
    }
}

#warning this
- (NSArray *)introSoundNames
{
    return nil;
}
- (NSArray *)frightenedSoundNames
{
    return nil;
}
- (NSArray *)deathSoundNames
{
    return nil;
}

- (CGFloat)zPosition
{
    // XXX this isn't doing anything, zPosition must be internal
    return ( self.position.y - self.parent.frame.origin.y ) / self.parent.frame.size.height * ( ENTITY_Z_MAX - ENTITY_Z ) + ENTITY_Z;
}

@end

@implementation SKNode (CombobulatedExtensions)

- (void)removeChildrenNamed:(NSString *)childName
{
    __block NSMutableArray *matchingChildren = [NSMutableArray new];
    [self.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
        if ( [childNode.name isEqualToString:childName] )
        {
            [matchingChildren addObject:childNode];
        }
    }];
    
    [self removeChildrenInArray:matchingChildren];
}

@end

