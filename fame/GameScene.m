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
            self.playerNode = sprite;
        else if ( [actor isKindOfClass:[Celeb class]] )
            self.celebNode = sprite;
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

#define MULTI_TAP_THRESHOLD 0.1

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

- (void)_playerAction:(NSString *)action targetPoint:(CGPoint)point
{
    point = [self _snapLocationToSidewalk:point];
    NSLog(@"%@: %0.2f,%0.2f",action, point.x, point.y);
    if ( [action isEqualToString:@"action1"] )
    {
        SKAction *moveAction = [SKAction moveTo:point duration:MOVE_SPEED];
        [self.playerNode runAction:moveAction];
    }
    if ( [action isEqualToString:@"action2"] )
    {
        SKAction *moveAction = [SKAction moveTo:point duration:MOVE_SPEED / 2];
        [self.playerNode runAction:moveAction];
    }
    if ( [action isEqualToString:@"action3"] )
    {
        SKAction *moveAction = [SKAction moveTo:point duration:MOVE_SPEED / 3];
        [self.playerNode runAction:moveAction];
    }
    else if ( [action isEqualToString:@"action4"] )
    {
        //NSLog(@"charge!");
        SKAction *moveAction = [SKAction moveTo:point duration:MOVE_SPEED / 5];
        [self.playerNode runAction:moveAction];
    }
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
    
    if ( ( arc4random() % 30 ) == 0 )
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
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if ( contact.bodyA == contact.bodyB )
        return; // XXX am i doing it wrong?
    //NSLog(@"%@ is no longer in contact with %@",contact.bodyA.node.name,contact.bodyB.node.name);
}

@end
