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

- (id)initWithImageNamed:(NSString *)name
{
    return [self initWithImageNamed:name withPhysics:YES];
}

- (id)initWithImageNamed:(NSString *)name withPhysics:(BOOL)withPhysics
{
    if ( ( self = [super initWithImageNamed:name] ))
    {
        self.name = name;
        self.zPosition = ENTITY_Z;
        self.texture.filteringMode = SKTextureFilteringNearest;
        
        if ( withPhysics )
        {
            SKPhysicsBody *physics = nil;
            CGSize collisionSize = self.collisionSize;
            if ( ! isnan(collisionSize.width) )
            {
                CGPoint collisionCenter = self.collisionCenter;
                physics = [SKPhysicsBody bodyWithRectangleOfSize:collisionSize center:collisionCenter];//[SKPhysicsBody bodyWithTexture:texture size:texture.size];
            }
            else // performs horrendously
                physics = [SKPhysicsBody bodyWithTexture:self.texture size:self.size];
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

- (CGSize)collisionSize
{
    return self.size;//CGSizeMake(NAN,NAN);
}

- (CGPoint)collisionCenter
{
    return self.position;
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

- (void)dispatchActionPause
{
    [self.actionDispatchSources enumerateObjectsUsingBlock:^(dispatch_source_t actionSource, NSUInteger idx, BOOL *stop) {
        dispatch_suspend(actionSource);
    }];
}

- (void)dispatchActionResume
{
    [self.actionDispatchSources enumerateObjectsUsingBlock:^(dispatch_source_t actionSource, NSUInteger idx, BOOL *stop) {
        dispatch_resume(actionSource);
    }];
}

- (SKAction *)actionForKey:(NSString *)key
{
    SKAction *theAction = [super actionForKey:key];
    if ( ! theAction )
        theAction = ((NSDictionary *)self.userData[MyActionsKey])[key];
    return theAction;
}

NSString *MyActionsKey = @"myActions";

- (void)runAction:(SKAction *)action withKey:(NSString *)key completion:(void (^)(void))block
{
    if ( ! self.userData[MyActionsKey] )
        self.userData[MyActionsKey] = [NSMutableDictionary new];
    ((NSMutableDictionary *)self.userData[MyActionsKey])[key] = action;
    
    [self runAction:action completion:^{
        [((NSMutableDictionary *)self.userData[MyActionsKey]) removeObjectForKey:key];
        block();
    }];
}

@end

@implementation SKNode (CombobulatedExtensions)

- (CGPoint)midpointToNode:(SKNode *)node
{
    CGFloat midX = ( node.position.x + self.position.x ) / 2;
    CGFloat midY = ( node.position.y + self.position.y ) / 2;
    return CGPointMake(midX,midY);
}

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

