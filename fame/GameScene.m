//
//  GameScene.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScene.h"

#import "Fame.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
    
    SKNode *parentNode = [SKNode new];
    [self addChild:parentNode];
    
    [self _addWorldToNode:parentNode];
    [self _addEntitiesToNode:parentNode];
    
    self.physicsWorld.contactDelegate = self;
    
    self.parentNode = parentNode;
    
//    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    tripleTap.numberOfTapsRequired = 3;
    //    [self.view addGestureRecognizer:tripleTap];
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    singleTap.numberOfTapsRequired = 1;
//    //[singleTap requireGestureRecognizerToFail:tripleTap];
//    [self.view addGestureRecognizer:singleTap];
//    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    //[doubleTap requireGestureRecognizerToFail:tripleTap];
//    [self.view addGestureRecognizer:doubleTap];
//    
//    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIPanGestureRecognizer *swipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:swipe];
}

- (void)_addEntitiesToNode:(SKNode *)node
{
    NSArray *startEntities = @[ [Celeb class], [Bouncer class] ];
    CGFloat xOffset = 0;
    for ( Class class in startEntities )
    {
        Actor *actor = [class new];
        SKSpriteNode *sprite = actor.node;
        sprite.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset,
                                      CGRectGetMidY(self.frame));
        xOffset = -(sprite.size.width * 1.1);
        
        [node addChild:sprite];
        
        if ( [actor isKindOfClass:[Bouncer class]] )
            self.bouncer = actor;
        else if ( [actor isKindOfClass:[Celeb class]] )
            self.celeb = actor;
    }
}

- (void)_addWorldToNode:(SKNode *)node
{
    NSNumber *foregroundSpeed = @( FOREGROUND_SPEED );
    NSNumber *foregroundZ = @( FOREGROUND_Z );
    NSNumber *backgroundSpeed = @( BACKGROUND_SPEED );
    NSNumber *backgroundZ = @( BACKGROUND_Z );
    NSArray *textureMap =           @[
                                      @{ @"name" : @"road1",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ },
                                      @{ @"name" : @"street1",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ },
                                      @{ @"name" : @"background1",
                                         @"speed" : backgroundSpeed,
                                         @"yOffset" : @( 300 ),
                                         @"zPosition" : backgroundZ }
                                      ];
    for ( NSDictionary *textureDict in textureMap )
        [self _addForegroundTextureToNode:node info:textureDict];
}

static CGFloat gLastYOffset = 0; // XXX
- (void)_addForegroundTextureToNode:(SKNode *)node info:(NSDictionary *)textureDict
{
    SKTexture *texture = [SKTexture textureWithImageNamed:textureDict[@"name"]];
    texture.filteringMode = SKTextureFilteringNearest; // antialiasing? yes
    
    double speedScalar = ((NSNumber *)textureDict[@"speed"]).doubleValue;
    
    SKAction *movement = [SKAction moveByX:(-texture.size.width * 2.0) y:0 duration:(speedScalar * texture.size.width * 2.0)];
    SKAction *resetTexture = [SKAction moveByX:(texture.size.width * 2.0) y:0 duration:0];
    SKAction *repeatForever = [SKAction repeatActionForever:[SKAction sequence:@[ movement, resetTexture ]]];
    
    CGFloat i;
    CGFloat spriteHeight = 0;
    for ( i = 0; i < 2.0 + self.frame.size.width / ( texture.size.width * 2.0 ); i++ )
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
        spriteHeight = sprite.size.height;
        [sprite setScale:2.0];
        
        // XXX
        NSNumber *yOffset = textureDict[@"yOffset"];
        if ( yOffset.doubleValue == 0 )
            yOffset = @(gLastYOffset);
        
        [sprite setPosition:CGPointMake(i * sprite.size.width, yOffset.doubleValue + spriteHeight)];
        [sprite runAction:repeatForever];
        
        sprite.zPosition = ((NSNumber *)textureDict[@"zPosition"]).doubleValue;
            
        [node addChild:sprite];
    }
    gLastYOffset += spriteHeight * 2;
}

// this is actually necessary
- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self tap:recognizer];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    [self tap:recognizer];
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    location = [self convertPointFromView:location];
    [self _handleNTaps:recognizer.numberOfTapsRequired atLocation:location];
    //NSLog(@"tap");
}

- (void)_handleNTaps:(NSUInteger)nTaps atLocation:(CGPoint)location
{
    NSString *action = [NSString stringWithFormat:@"action%lu",nTaps];
    [self _playerAction:action targetPoint:location];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat sumVelocity = ( velocity.x > 0) ? velocity.x : -(velocity.x);
        sumVelocity += ( velocity.y > 0 ) ? velocity.y : -(velocity.y);
        if ( sumVelocity < VELOCITY_THRESHOLD )
            return;
        //NSLog(@"pan velocity: %0.2f,%0.2f",velocity.x,velocity.y);
        CGPoint location = [recognizer locationInView:self.view];
        location = [self convertPointFromView:location];
        [self _playerAction:@"action4" targetPoint:location];
    }
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        NSLog(@"touch: %0.2f,%0.2f",location.x,location.y);
//    }
//}

#define MULTI_TAP_THRESHOLD 0.2

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for ( UITouch *touch in touches )
    {
        if ( touch.tapCount == 1 )
        {
            self.firstTapLocation = [touch locationInNode:self];
        }
        
        NSDate *nowAndLater = [NSDate date];
        self.lastTapDate = nowAndLater;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MULTI_TAP_THRESHOLD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( nowAndLater == self.lastTapDate )
                [self _handleNTaps:touch.tapCount atLocation:self.firstTapLocation];
        });
    }
//    NSLog(@"====================================================================================================");
//    NSLog(@"====================================================================================================");
//    NSLog(@"====================================================================================================");
//    NSLog(@"====================================================================================================");
//    NSLog(@"====================================================================================================");
//    NSLog(@"touches began: %@",touches);
//    NSLog(@"event: %@",event);
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
////    NSLog(@"touches ended: %@",touches);
////    NSLog(@"event: %@",event);
////    NSLog(@"====================================================================================================");
////    NSLog(@"====================================================================================================");
////    NSLog(@"====================================================================================================");
////    NSLog(@"====================================================================================================");
////    NSLog(@"====================================================================================================");
//    
//    for ( UITouch *touch in touches )
//    {
//        if ( touch.tapCount > 1 && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < MULTI_TAP_THRESHOLD )
//            ; // ignore and keep counting
//    }
//}

#define JUMP_HEIGHT 150.0
#define EARTHQUAKE_RADIUS 200.0

- (void)_playerAction:(NSString *)action targetPoint:(CGPoint)point
{
    point = [self _snapLocationToSidewalk:point];
    NSLog(@"%@: %0.2f,%0.2f",action, point.x, point.y);
    NSString *soundName = nil;
    
    if ( [action isEqualToString:@"action1"] )
    {
        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION];
        [self.bouncer.node runAction:moveAction];
        soundName = [self _randomGrunt:YES];
    }
    if ( [action isEqualToString:@"action2"] )
    {
        CGPoint airPoint = CGPointMake(point.x, self.bouncer.node.position.y + JUMP_HEIGHT);
        SKAction *flyAction = [SKAction moveTo:airPoint duration:STANDARD_MOVE_DURATION / 3];
        self.bouncer.isAirborne = YES;
        [self.bouncer.node runAction:flyAction completion:^{
            SKPhysicsBody *origPhysics = self.bouncer.node.physicsBody;
            self.bouncer.node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:EARTHQUAKE_RADIUS];
            NSTimeInterval landTime = STANDARD_MOVE_DURATION / 3;
            SKAction *landAction = [SKAction moveTo:point duration:landTime];
            //NSTimeInterval activateTime = landTime / 2;
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(activateTime * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            // XXX this is a hack
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //NSLog(@"eagle is active");
                self.bouncer.isAirborne = NO;
            });
            //NSLog(@"landing");
            [self _playSoundNamed:[self _randomScream:YES]];
            [self.bouncer.node runAction:landAction completion:^{
//                [self.parentNode.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
//                    if ( ! [childNode.name isEqualToString:@"bouncer"]
//                            && [self.bouncer.node intersectsNode:childNode] )
//                            NSLog(@"I hit %@",childNode.name);
//                }];
                //NSLog(@"eagle has landed");
                self.bouncer.node.physicsBody = origPhysics;
                [self _playSoundNamed:[self _randomBoom]];
            }];
            
        }];
    }
//    if ( [action isEqualToString:@"action3"] )
//    {
//        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION / 3];
//        [self.playerNode runAction:moveAction];
//        soundName = [self _randomScream:YES];
//    }
//    else if ( [action isEqualToString:@"action4"] )
//    {
//        //NSLog(@"charge!");
//        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION / 5];
//        [self.playerNode runAction:moveAction];
//        soundName = [self _randomScream:YES];
//    }
    
    [self _playSoundNamed:soundName];
}

- (void)_playSoundNamed:(NSString *)soundName
{
    if ( soundName )
    {
        SKAction *soundEffect = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
        [self runAction:soundEffect];
    }
}

NSInteger   gMaxBoom = -1;
- (NSString *)_randomBoom
{
    NSString *base = @"";
    NSString *type = @"boom";
    NSInteger *idx = &gMaxBoom;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

NSInteger   gMaxMaleGrunt = -1,
            gMaxFemaleGrunt = -1;
- (NSString *)_randomGrunt:(BOOL)male
{
    NSString *base = male ? @"male_" : @"female_";
    NSString *type = @"grunt";
    NSInteger *idx = male ? &gMaxMaleGrunt : &gMaxFemaleGrunt;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

- (void)_loadMaxSoundFileIdxWithBase:(NSString *)base type:(NSString *)type storage:(NSInteger *)storage
{
    NSInteger testIdx = 1;
    NSString *fileName = nil;
    while ( ( fileName = [NSString stringWithFormat:@"%@%@_%02u",base,type,(unsigned)testIdx] ) &&
        [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"] )
        testIdx++;
    *storage = testIdx - 1;
}

NSInteger   gMaxMaleScream = -1,
            gMaxFemaleScream = -1;
- (NSString *)_randomScream:(BOOL)male
{
    NSString *base = male ? @"male_" : @"female_";
    NSString *type = @"scream";
    NSInteger *idx = male ? &gMaxMaleScream : &gMaxFemaleScream;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@_%02u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
}

- (CGPoint)_snapLocationToSidewalk:(CGPoint)point
{
    CGPoint snappedPoint = point;
    
    if ( snappedPoint.y > TOP_SIDEWALK_UPPER )
        snappedPoint.y = TOP_SIDEWALK_UPPER;
    else if ( snappedPoint.y < BOTTOM_SIDEWALK_LOWER )
        snappedPoint.y = BOTTOM_SIDEWALK_LOWER;
    
    return snappedPoint;
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if ( ( arc4random() % 10 ) == 0 )
        [self _addRandomAI];
}

- (void)_addRandomAI
{
    static NSArray *gAITypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gAITypes = @[ [Pedestrian class] ];
    });
    
    NSUInteger idx = arc4random() % gAITypes.count;
    Class aiClass = gAITypes[idx];
    //NSLog(@"let's add a %@",aiClass);
    Actor *ai = [aiClass new];
    [self.parentNode addChild:ai.node];
    [ai introduceWithFrame:self.frame];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ( contact.bodyA == contact.bodyB )
        return; // XXX am i doing it wrong?
    //NSLog(@"%@ is in contact with %@",contact.bodyA.node.name,contact.bodyB.node.name);
    
    SKPhysicsBody *pedPhysics = nil;
    SKPhysicsBody *bouncerPhysics = nil;
    SKPhysicsBody *celebPhysics = nil;
    if ( [contact.bodyA.node.name isEqualToString:@"bouncer"] )
        bouncerPhysics = contact.bodyA;
    else if ([contact.bodyB.node.name isEqualToString:@"bouncer"] )
        bouncerPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name isEqualToString:@"celeb"] )
        celebPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name isEqualToString:@"celeb"] )
        celebPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name isEqualToString:@"pedestrian"] )
        pedPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name isEqualToString:@"pedestrian"] )
        pedPhysics = contact.bodyB;
    
    if ( bouncerPhysics && pedPhysics )
    {
        //NSLog(@"bouncer->ped %0.2f,%0.2f",contact.contactNormal.dx,contact.contactNormal.dy);
        //[pedPhysics applyImpulse:contact.contactNormal];
        
        if ( self.bouncer.isAirborne )
        {
            //NSLog(@"ignoring airborne player collision");
            return;
        }
        
        NSTimeInterval flightTime = 1;
        CGFloat randomX = ( arc4random() % 1000 );
        SKAction *flyAway = [SKAction moveTo:CGPointMake(randomX,FLYAWAY_Y) duration:flightTime];
        SKAction *spin = [SKAction rotateByAngle:4*M_PI duration:flightTime];
        SKAction *shrink = [SKAction scaleBy:0.25 duration:flightTime];
        SKAction *flyAwaySpinAndShrink = [SKAction group:@[ flyAway, spin, shrink ]];
        SKNode *node = pedPhysics.node;
        [node removeAllActions];
        [node runAction:flyAwaySpinAndShrink completion:^{
            SKAction *disappear = [SKAction fadeOutWithDuration:0.25];
            [node runAction:disappear completion:^{
                [pedPhysics.node removeFromParent];
            }];
        }];
    }
    else if ( celebPhysics && pedPhysics )
    {
        //NSLog(@"ped->celeb spin %0.2f, %0.2f",contact.contactNormal.dx,contact.contactNormal.dy);
        CGFloat angle = contact.contactNormal.dx > 0 ? 2*M_PI : -(2*M_PI);
        SKAction *action = [SKAction rotateByAngle:angle duration:1];
        [celebPhysics.node runAction:action];
        NSString *sound = [self _randomScream:NO];
        SKAction *scream = [SKAction playSoundFileNamed:sound waitForCompletion:NO];
        [self runAction:scream];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if ( contact.bodyA == contact.bodyB )
        return; // XXX am i doing it wrong?
    //NSLog(@"%@ is no longer in contact with %@",contact.bodyA.node.name,contact.bodyB.node.name);
}

@end
