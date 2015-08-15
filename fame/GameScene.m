//
//  GameScene.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScene.h"

#import "MyPanGestureRecognizer.h"

#ifdef MYDEBUG //TARGET_IPHONE_SIMULATOR
#define DEBUG_MASKS
#else
#undef DEBUG_MASKS
#endif

#define BOTTOM_SIDEWALK_LOWER backgroundSprite.size.height
#define BOTTOM_SIDEWALK_UPPER ( BOTTOM_SIDEWALK_LOWER + 40.0 )
#define TOP_SIDEWALK_LOWER ( BOTTOM_SIDEWALK_UPPER + 297 )
#define TOP_SIDEWALK_UPPER ( TOP_SIDEWALK_LOWER + 60.0 )

@interface GameScene (RefactorMe)
- (void)_runEarthquakeAtPoint:(CGPoint)point;
@end

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
    parentNode.name = @"root";
    [self addChild:parentNode];
    
    self.gameScreenMap = [GameScreenMap new];
    self.gameScreenMap.screenRect = self.frame;
    
    [self _addWorldToNode:parentNode];
    [self _addFriendliesToNode:parentNode];
    
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
    
    _panRecognizer = [[MyPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:_panRecognizer];
}

- (void)_addFriendliesToNode:(SKNode *)node
{
    NSArray *startEntities = @[ [Pedestrian class], [Bouncer class], [Celeb class] ];
    CGFloat xOffset = 0;
    for ( Class class in startEntities )
    {
        EntityNode *entityNode = [class new];
        entityNode.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset,
                                      CGRectGetMidY(self.frame) - 200);
        xOffset -= (entityNode.size.width * 1.5);
        
        [node addChild:entityNode];
        
        BOOL isBouncer = [entityNode isKindOfClass:[Bouncer class]];
        if ( isBouncer )
            self.bouncer = (Bouncer *)entityNode;
        else
            self.celeb = (Celeb *)entityNode;
 
#define ENABLE_WALK
#ifdef ENABLE_WALK
        CGFloat stepTime = isBouncer ? 0.5 : 0.7;
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, stepTime * NSEC_PER_SEC, stepTime * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            //SKAction *flipAction = [SKAction scaleXTo:-(sprite.xScale) duration:0];
            if ( ! entityNode.isMidAction )
                entityNode.xScale = -(entityNode.xScale);
            //[sprite runAction:flipAction];
        });
        dispatch_resume(timer);
        
        entityNode.actionDispatchSources = @[ timer ];
#endif
    }
}

- (void)_addWorldToNode:(SKNode *)node
{
    NSNumber *foregroundSpeed = @( FOREGROUND_SPEED );
    NSNumber *foregroundZ = @( FOREGROUND_Z );
    NSNumber *backgroundSpeed = @( BACKGROUND_SPEED );
    NSNumber *backgroundZ = @( BACKGROUND_Z );
    
    //typedef void (^handler)(GameScene *scene,SKNode *node);
    //void (^handlerCopy)(NSURLResponse*, NSData*, NSError*) = Block_copy(handler);
    //[dict setObject:handlerCopy forKey:@"foo"];
    //Block_release(handlerCopy);
    
    NSArray *textureMap =           @[
                                      @{ @"name" : @"road1",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ,
                                         @"setKey" : @"streetNode" },
                                      @{ @"name" : @"street2",
                                         @"speed" : foregroundSpeed,
                                         @"yOffset" : @( 0 ),
                                         @"zPosition" : foregroundZ,
                                         @"setKey" : @"cityNode",
                                         @"nFrames" : @(10) },
                                      @{ @"name" : @"background1",
                                         @"speed" : backgroundSpeed,
                                         @"yOffset" : @( 300 ),
                                         @"zPosition" : backgroundZ,
                                         @"setKey" : @"backgroundNode" }
                                      ];
    [self _addControlPanel:node];
    for ( NSDictionary *textureDict in textureMap )
        [self _addForegroundTextureToNode:node info:textureDict];
}

static CGFloat gLastYOffset = 0; // XXX

- (void)_addControlPanel:(SKNode *)node
{
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"control-panel-1"];
    backgroundTexture.filteringMode = SKTextureFilteringNearest;
    
    CGFloat scale = 1.0;
    
    SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    backgroundSprite.zPosition = CONTROL_PANEL_Z;
    NSLog(@"%0.2f,%0.2f - %0.2f,%0.2f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    CGFloat magicalMysteryNumber = 647/2; // XXX
    CGPoint fuckingBottomLeft = CGPointMake(magicalMysteryNumber, backgroundTexture.size.height / 2);
    backgroundSprite.xScale = 5.0 * scale;
    backgroundSprite.yScale = 1.0 * scale;
    backgroundSprite.position = fuckingBottomLeft;
    
    [node addChild:backgroundSprite];
    gLastYOffset += backgroundSprite.size.height;
    self.gameScreenMap.bottomSidewalkLower = backgroundSprite.size.height;
    self.gameScreenMap.bottomSidewalkUpper = BOTTOM_SIDEWALK_UPPER;
    self.gameScreenMap.streetLower = BOTTOM_SIDEWALK_UPPER;
    self.gameScreenMap.streetUpper = TOP_SIDEWALK_LOWER;
    self.gameScreenMap.topSidewalkLower = TOP_SIDEWALK_LOWER;
    self.gameScreenMap.topSidewalkUpper = TOP_SIDEWALK_UPPER;
    self.gameScreenMap.streetLeft = self.frame.origin.x;
    self.gameScreenMap.streetRight = self.frame.origin.x + self.frame.size.width;
    
    CGFloat xOffset = 0;
    NSArray *buttonNames = @[ @"move-button-1", @"earthquake-button-1", @"move-button-1" ];
    
    int idx = 1;
    for ( ; idx <= buttonNames.count ; idx++ )
    {
        NSString *buttonName = buttonNames[idx - 1];
        Button *aButton = [Button buttonWithName:buttonName origin:fuckingBottomLeft xOffset:xOffset];
        [node addChild:aButton];
        xOffset += ( idx == buttonNames.count ? 0 : aButton.size.width ) + 1;//buttonFrameSprite.size.width * 1.05 * scale;
        [self setValue:aButton forKey:[NSString stringWithFormat:@"button%d",idx]];
        
        //[buttonFrameSprite runAction:rotateForever];
        //[buttonContentNode runAction:rotateForever];
    }
    
    Meter *meter = [Meter meterWithLabel:@"anger" origin:fuckingBottomLeft xOffset:xOffset];
    [node addChild:meter];
    self.meter1 = meter;
    
    //[backgroundSprite runAction:rotateForever];
}

- (void)_angerDelta:(NSInteger)angerDelta
{
    NSInteger origAnger = self.bouncer.anger;
    NSInteger netAnger = origAnger + angerDelta;
    if ( netAnger > MAX_ANGER )
        netAnger = MAX_ANGER;
    if ( netAnger < 0 )
        netAnger = 0;
    
    NSInteger realAngerDelta = netAnger - origAnger;
    //NSLog(@"ad %ld orig %ld net %ld real %ld",angerDelta,origAnger,netAnger,realAngerDelta);
    
    self.bouncer.anger = netAnger;
    
    //NSLog(@"anger %ld + d%ld -> %lu",(long)origAnger,(long)angerDelta,(unsigned long)self.bouncer.anger);
    
    __block int frame = 0;
    NSTimeInterval duration = 0.5;//, frameInterval = 10 / duration, nFrames = duration / frameInterval;
    CGFloat origXScale = self.meter1.fillerNode.xScale;
    CGFloat origX = self.meter1.fillerNode.position.x;
    SKAction *setAction = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double perc = elapsedTime / duration;
        if ( frame < ( perc * 10 ) )
        {
            SKSpriteNode *fillerNode = (SKSpriteNode *)node;
            CGFloat xDelta = perc * (float)realAngerDelta;
            CGFloat drawnDelta = origXScale + xDelta;
            if ( drawnDelta < METER_FILLER_MIN_SCALE )
                drawnDelta = METER_FILLER_MIN_SCALE;
            fillerNode.xScale = origXScale + xDelta;
            fillerNode.position = CGPointMake( origX + xDelta / 2, fillerNode.position.y );
            frame++;
        }
    }];
    
    [self.meter1.fillerNode runAction:setAction];
}

- (void)_addForegroundTextureToNode:(SKNode *)node info:(NSDictionary *)textureDict
{
    NSString *baseTexturePrefix = textureDict[@"name"];
    NSNumber *nFrames = textureDict[@"nFrames"];
    BOOL animatedLayer = ( nFrames.integerValue > 0 );
    NSString *baseTextureName = animatedLayer ? [NSString stringWithFormat:@"%@-1",baseTexturePrefix] : baseTexturePrefix;
    SKTexture *texture = [SKTexture textureWithImageNamed:baseTextureName];
    texture.filteringMode = SKTextureFilteringNearest; // antialiasing? yes
    
    double speedScalar = ((NSNumber *)textureDict[@"speed"]).doubleValue;
    
    CGFloat foregroundScale = 2.0;
    CGFloat foregroundXMovement = (-texture.size.width * foregroundScale);
    self.foregroundXMovementTime = (speedScalar * texture.size.width * foregroundScale);
    SKAction *foregroundMovement = [SKAction moveByX:foregroundXMovement y:0 duration:self.foregroundXMovementTime];
    
    NSMutableArray *groupActions = [NSMutableArray arrayWithObject:foregroundMovement];
    NSTimeInterval timeToPan = self.frame.size.width / -foregroundXMovement;
    CGFloat animateCount = 6.0;
    NSTimeInterval frameDuration = timeToPan / animateCount * 1.25;
    if ( animatedLayer )
    {
        int idx = 0;
        NSMutableArray *animateTextures = [NSMutableArray new];
        for ( ; idx < nFrames.integerValue; idx++ )
        {
            SKTexture *aTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-%d",baseTexturePrefix,idx + 1]];
            aTexture.filteringMode = SKTextureFilteringNearest;
            [animateTextures addObject:aTexture];
        }
        NSLog(@"%@ will animate with %d textures",baseTextureName,idx);
        [groupActions addObject:[SKAction repeatAction:[SKAction animateWithTextures:animateTextures timePerFrame:frameDuration resize:YES restore:NO] count:animateCount]];
    }
    SKAction *resetTexture = [SKAction moveByX:(texture.size.width * foregroundScale) y:0 duration:0];
    SKAction *moveAndAnimate = [SKAction group:groupActions];
    SKAction *repeatForever = [SKAction repeatActionForever:[SKAction sequence:@[ moveAndAnimate, resetTexture ]]];
    
    CGFloat i;
    CGFloat spriteHeight = 0;
    for ( i = 0; i < 2.0 + self.frame.size.width / ( texture.size.width * foregroundScale ); i++ )
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
        spriteHeight = sprite.size.height;
        [sprite setScale:foregroundScale];
        
        // XXX
        NSNumber *yOffset = textureDict[@"yOffset"];
        if ( yOffset.doubleValue == 0 )
            yOffset = @(gLastYOffset);
        
        [sprite setPosition:CGPointMake(i * sprite.size.width, yOffset.doubleValue + spriteHeight)];
        [sprite runAction:repeatForever];
        
        sprite.zPosition = ((NSNumber *)textureDict[@"zPosition"]).doubleValue;
            
        [node addChild:sprite];
    }
    self.foregroundXMovement = i * foregroundXMovement;
    gLastYOffset += spriteHeight * foregroundScale;
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
    [self _handleNTaps:recognizer.numberOfTapsRequired nFingers:recognizer.numberOfTouches atLocation:location];
    //NSLog(@"tap");
}

- (void)_handleNTaps:(NSUInteger)nTaps nFingers:(NSUInteger)nFingers atLocation:(CGPoint)location
{
    NSString *base = nil;
    if ( nFingers == 1 )
        base = @"";
    if ( nFingers == 2 )
        base = @"double-";
    else if ( nFingers == 3 )
        base = @"triple-";
    else if ( nFingers == 4 )
        base = @"quadruple-";
    else if ( nFingers == 5 )
        base = @"quintuple-";
    NSString *action = [NSString stringWithFormat:@"%@action-%u",base,(unsigned)nTaps];
    [self _playerAction:action targetPoint:location];
}

- (void)pan:(MyPanGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        CGPoint startPoint = [self convertPointFromView:recognizer.currentStartPoint];
        if ( ! CGRectContainsPoint(ScaledRect(self.bouncer.frame,2.0),startPoint ) )
            return;
        
        [_panRecognizer reset];
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat sumVelocity = ( velocity.x > 0) ? velocity.x : -(velocity.x);
        sumVelocity += ( velocity.y > 0 ) ? velocity.y : -(velocity.y);
        if ( sumVelocity < VELOCITY_THRESHOLD )
            return;
        //NSLog(@"pan velocity: %0.2f,%0.2f",velocity.x,velocity.y);
        CGPoint location = [recognizer locationInView:self.view];
        //NSLog(@"pan %@ -> %@",PointString(startPoint),PointString(location));
        location = [self convertPointFromView:location];
        [self _playerAction:@"action-4" targetPoint:location];
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
            CGPoint skStartPoint = [self convertPointFromView:_panRecognizer.currentStartPoint];
            if ( CGPointEqualToPoint(self.firstTapLocation, skStartPoint) )
            {
                //NSLog(@"eating %@ being tracked by pan recognizer",PointString(self.firstTapLocation));
                return;
            }
            if ( nowAndLater == self.lastTapDate )
                [self _handleNTaps:touch.tapCount nFingers:touches.count atLocation:self.firstTapLocation];
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touches ended: %@",touches);
    NSString *string = nil;
    if ( touches.count == 2 )
        string = @"double";
    else if ( touches.count == 3 )
        string = @"triple";
    else if ( touches.count == 4 )
        string = @"quadruple";
    else if ( touches.count == 5 )
        string = @"quintuple";
    else if ( touches.count > 1 )
        string = [NSString stringWithFormat:@"n-%u",(unsigned)touches.count];
    
    if ( string )
        NSLog(@"appears to be a %@ %u tap",string,(unsigned)((UITouch *)touches.anyObject).tapCount);
}
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

- (void)_flashButton:(int)idx
{
    SKSpriteNode *theButton = [self valueForKey:[NSString stringWithFormat:@"button%d",idx]];
    if ( ! theButton )
        return;
    
    UIColor *defaultColor = theButton.color;
    CGFloat defaultBlendFactor = theButton.colorBlendFactor;
    NSTimeInterval flashDuration = 0.25;
    SKAction *flash1 = [SKAction colorizeWithColor:[[UIColor redColor] colorWithAlphaComponent:0.5] colorBlendFactor:0.5 duration:flashDuration];
    SKAction *flash2 = [SKAction colorizeWithColor:defaultColor colorBlendFactor:defaultBlendFactor duration:flashDuration];
    SKAction *flash = [SKAction sequence:@[ flash1, flash2 ]];
    //SKAction *flashTwice = [SKAction repeatAction:flash count:2];
    
    NSTimeInterval growDuration = flashDuration;
    CGFloat defaultX = theButton.xScale, defaultY = theButton.yScale;
    CGFloat scaleTo = 1.1;
    SKAction *grow = [SKAction scaleBy:scaleTo duration:growDuration];
    SKAction *shrink = [SKAction scaleXTo:defaultX y:defaultY duration:growDuration];
    SKAction *growAndShrink = [SKAction sequence:@[ grow, shrink ]];
    
    [theButton runAction:flash];
    [theButton runAction:growAndShrink];
    
    [self _playSoundNamed:@"no-beep.wav"];
}

- (void)_playerAction:(NSString *)action targetPoint:(CGPoint)point
{
    if ( self.bouncer.isMidAction
        && ! self.bouncer.currentActionIsInterruptible
        && ! [@[ @"double-action-1" ] containsObject:action] )
    {
        NSLog(@"ignoring %@ because player is mid non-interruptible action",action);
        return;
    }
    
    point = [self _snapLocationOfNode:self.bouncer toSidewalk:point];
    NSLog(@"%@: %0.2f,%0.2f",action, point.x, point.y);
    NSString *soundName = nil;
    NSInteger angerDelta = 0;
    
    if ( [action isEqualToString:@"action-1"] )
    {
        if ( self.bouncer.lastMove )
        {
            [self _flashButton:1];
            return;
        }
        [self _walkNode:self.bouncer to:point];
        soundName = [self _randomGrunt:YES];
        self.bouncer.lastMove = [NSDate date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MOVE_CD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.bouncer.lastMove = nil;
        });
        angerDelta = MOVE_ANGER;
    }
    else if ( [action isEqualToString:@"action-2"] )
    {
        if ( self.bouncer.lastEarthquake )
        {
            [self _flashButton:2];
            return;
        }
        [self _runEarthquakeAtPoint:point];
        angerDelta = EARTHQUAKE_ANGER;
    }
//    if ( [action isEqualToString:@"action-3"] )
//    {
//        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION / 3];
//        [self.bouncer.node runAction:moveAction];
//        soundName = [self _randomScream:YES];
//    }
    else if ( [action isEqualToString:@"action-4"] )
    {
        //NSLog(@"charge!");
        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION / 5];
        [self.bouncer runAction:moveAction];
        soundName = [self _randomScream:YES];
        self.bouncer.lastCharge = [NSDate date];
        angerDelta = CHARGE_ANGER;
    }
    else if ( [action isEqualToString:@"double-action-1"] )
    {
        [self _togglePause:self.parentNode];
    }
    else if ( [action isEqualToString:@"triple-action-1"] )
    {
        [self _walkNode:self.celeb to:self.bouncer.position];
        [self _playSoundNamed:@"whistle-1.wav"];
    }
    
    if ( angerDelta )
        [self _angerDelta:angerDelta];
    [self _drawCooldownClock];
    [self _playSoundNamed:soundName];
}

- (void)_drawCooldownClock
{
    NSString *cooldownKey = @"cooldown";
    NSTimeInterval cooldownDuration = 1;
    int idx = 1;
    for ( ; idx <= 4; idx++ )
    {
        SKSpriteNode *buttonNode = [self valueForKey:[NSString stringWithFormat:@"button%d",idx]];
        if ( ! buttonNode )
            break;
        
        if ( idx == 1 )
            cooldownDuration = MOVE_CD;
        else if ( idx == 2 )
            cooldownDuration = EARTHQUAKE_CD;
        else if ( idx == 3 )
            cooldownDuration = CHARGE_CD;
        
        SKAction *customAction = [SKAction customActionWithDuration:cooldownDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            double percentage;
            
            NSDate *lastActionDate;
            if ( idx == 1 )
                lastActionDate = self.bouncer.lastMove;
            else if ( idx == 2 )
                lastActionDate = self.bouncer.lastEarthquake;
            else if ( idx == 3 )
                lastActionDate = self.bouncer.lastCharge;
            else
                return;
            
            if ( lastActionDate )
            {
                double subPerc = ( [[NSDate date] timeIntervalSinceDate:lastActionDate] / cooldownDuration );
                if ( subPerc > 1 )
                    subPerc = 1;
                percentage = subPerc;
            }
            else
                percentage = 0;
            
            if ( percentage <= 0 || percentage > 1 )
                return;
            
            double cooldownInDegress = percentage * 360.0;
            double theta = ( cooldownInDegress + 90 );
            if ( theta > 360 )
                theta -= 360;
            double thetaRadians = theta * ( M_PI / 180 );
            CGPoint unitPoint = CGPointMake(cos(thetaRadians), sin(thetaRadians));
            
            CGPoint midPoint = CGPointMake( buttonNode.size.width / 2, buttonNode.size.height / 2 );
            CGPoint unitPointScaled = CGPointMake(midPoint.x + ( unitPoint.x * ( buttonNode.size.width / 2 ) ), midPoint.y - ( unitPoint.y * ( buttonNode.size.height / 2 )));
            CGFloat slope = ( unitPointScaled.y - midPoint.y ) / ( unitPointScaled.x - midPoint.x );
            CGPoint endPoint = {0};
            
            //CGSize scaledSize = CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, buttonNode.size.height)];
            [path addLineToPoint:CGPointMake(buttonNode.size.width / 2, buttonNode.size.width)];
            [path addLineToPoint:CGPointMake(midPoint.x, midPoint.y)];
            
            // y = mx + b
            // y intercept  b = y - mx
            //              b =
            //              x = ( y - b ) / m
            CGFloat b = midPoint.y - slope * midPoint.x;
            double rotatedByDegrees = cooldownInDegress;
            CGFloat x = 0, y = 0;
            if ( rotatedByDegrees > 315 || rotatedByDegrees <= 45 ) // solve for x along the top
            {
                x = ( ( buttonNode.size.height ) - b ) / slope;
                endPoint = CGPointMake( x, buttonNode.size.height );
            }
            else if ( rotatedByDegrees > 45 && rotatedByDegrees <= 135 ) // solve for y along the right
            {
                y = slope * ( buttonNode.size.width ) + b;
                endPoint = CGPointMake( buttonNode.size.width, y );
            }
            else if ( rotatedByDegrees > 135 && rotatedByDegrees <= 225 ) // solve for x along the bottom
            {
                x = ( -b ) / slope;
                endPoint = CGPointMake( x, 0 );
            }
            else // solve for y along the left
            {
                y = slope + b;
                endPoint = CGPointMake( 0, y );
            }
            
            if ( isnan(endPoint.x) || isnan(endPoint.y) )
            {
                // XXX NSLog(@"cooldown clock nan bug happened");
                return;
            }
            
            [path addLineToPoint:CGPointMake(endPoint.x, endPoint.y)]; // the mystery point
            if ( rotatedByDegrees <= 45 ) // TOP RIGHT
                [path addLineToPoint:CGPointMake(buttonNode.size.width, buttonNode.size.height)];
            if ( rotatedByDegrees <= 135 ) // BOTTOM RIGHT
                [path addLineToPoint:CGPointMake(buttonNode.size.width, 0)];
            if ( rotatedByDegrees <= 225 ) // BOTTOM LEFT
                [path addLineToPoint:CGPointMake(0, 0)];
            if ( rotatedByDegrees <= 315 ) // TOP LEFT
                [path addLineToPoint:CGPointMake(0, buttonNode.size.height)];
            
            SKShapeNode *shape = [SKShapeNode shapeNodeWithPath:path.CGPath];
            shape.name = cooldownKey;
            shape.xScale = 1 / buttonNode.xScale;
            shape.yScale = 1 / buttonNode.yScale;
            shape.zPosition = CONTROL_PANEL_CD_Z;
            //CGFloat magicalMysteryNumber = 647/2; // XXX
            //CGRect pathBounds = [path bounds];
            shape.position = CGPointMake(-buttonNode.size.width - 5,-buttonNode.size.height - 5); // XXX -5? //CGPointMake(magicalMysteryNumber/2 - /*path.bounds.*/self.button1.size.width / 2, shape.position.y - /*path.bounds.*/self.button1.size.height / 2);
            //shape.xScale = 1/0.45 * shape.xScale;
            //shape.yScale = -(1/0.45 * shape.xScale);
            //shape.position = CGPointMake(shape.position.x-450, shape.position.y + 20);
            shape.fillColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75];
            shape.strokeColor = [UIColor clearColor];
            
            SKNode *lastCC = [buttonNode childNodeWithName:cooldownKey];
            if ( lastCC )
                [buttonNode removeChildrenInArray:@[lastCC]];
            
            [buttonNode addChild:shape];
            
        }];
        
        [buttonNode runAction:customAction completion:^{
            [buttonNode removeChildrenNamed:cooldownKey];
        }];
    }
}

- (void)_togglePause:(SKNode *)node
{
    BOOL pausing = ! node.paused;
    node.paused = ! node.paused;
    
    [self __togglePause:pausing node:node];
    
    [node.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
        [self __togglePause:pausing node:childNode];
    }];
}

- (void)__togglePause:(BOOL)pausing node:(SKNode *)node
{
    if ( [node isKindOfClass:[EntityNode class]] )
    {
        [((EntityNode *)node).actionDispatchSources enumerateObjectsUsingBlock:^(dispatch_source_t actionSource, NSUInteger idx, BOOL *stop) {
            if ( pausing )
                dispatch_suspend(actionSource);
            else
                dispatch_resume(actionSource);
        }];
    }
}

- (void)_walkNode:(SKNode *)node to:(CGPoint)point
{
    SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION];
    __block float stepped = 0, steps = 5;
    SKAction *customAction = [SKAction customActionWithDuration:STANDARD_MOVE_DURATION actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double perc = elapsedTime / STANDARD_MOVE_DURATION;
        //NSLog(@"perc: %0.2f, %0.2f / %0.0f * %0.0f",perc, STANDARD_MOVE_DURATION,steps,stepped);
        if ( stepped / steps >= perc )
        {
            node.xScale = -node.xScale;
            stepped++;
        }
    }];

    __block BOOL isBouncer = NO;
    if ( [node.name hasPrefix:@"bouncer-"] )
    {
        isBouncer = YES;
        self.bouncer.isMidAction = YES;
        self.bouncer.currentActionIsInterruptible = YES;
    }
    
    //SKAction *walkAction = [SKAction animateWithTextures:@[ self.bouncer.node.texture ] timePerFrame:0.1];
    SKAction *group = [SKAction group:@[ moveAction, customAction]];
    [node runAction:group completion:^{
        if ( node.xScale < 0 )
            node.xScale = -(node.xScale);
        self.bouncer.isMidAction = NO;
        self.bouncer.currentActionIsInterruptible = NO;
    }];
}

- (NSArray *)_texturesForAnimation:(NSString *)animationName
{
    return [self _texturesForAnimation:animationName startFrame:1];
}

- (NSArray *)_texturesForAnimation:(NSString *)animationName startFrame:(NSInteger)startFrame
{
    return [self _texturesForAnimation:animationName startFrame:startFrame endFrame:0];
}

- (NSArray *)_texturesForAnimation:(NSString *)animationName endFrame:(NSInteger)endFrame
{
    return [self _texturesForAnimation:animationName startFrame:0 endFrame:endFrame];
}

- (NSArray *)_texturesForAnimation:(NSString *)animationName startFrame:(NSInteger)startFrame endFrame:(NSInteger)endFrame
{
    NSInteger idx = startFrame > 0 ? startFrame : 1;
    NSInteger lastFrameIdx = 0;
    if ( endFrame > 0 )
        lastFrameIdx = endFrame;
    else
    {
        if ( [animationName isEqualToString:@"earthquake"] )
            lastFrameIdx = 10;
        else
            lastFrameIdx = startFrame;
    }
    NSMutableArray *textures = [NSMutableArray new];
    for ( ; idx <= lastFrameIdx; idx++ )
    {
        // SKTexture returns a 'placeholder' for non-existant images, making it ineffective for testing above
        // and -NSBundle mainBundle can't seem to find "image assets"
        NSString *filename = [NSString stringWithFormat:@"%@%d",animationName,(int)idx];
        SKTexture *aTexture = [SKTexture textureWithImageNamed:filename];
        [textures addObject:aTexture];
    }
    
    if ( idx == 1 )
        return nil;
    return textures;
}

- (void)_playSoundNamed:(NSString *)soundName
{
    if ( soundName )
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SKAction *soundEffect = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
            [self runAction:soundEffect];
        });
    }
}

NSInteger   gMaxSlotSpin = -1;
- (NSString *)_randomSlotSpin
{
    NSString *base = @"";
    NSString *type = @"slot-machine-spin";
    NSInteger *idx = &gMaxSlotSpin;
    if ( *idx == -1 )
        [self _loadMaxSoundFileIdxWithBase:base type:type delimiter:@"-" numberFormat:@"%d" storage:idx];
    
    return *idx > 0 ? [NSString stringWithFormat:@"%@%@-%u.wav",base,type,(unsigned)( arc4random() % *idx + 1)] : nil;
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

// XXX GROSS
- (void)_loadMaxSoundFileIdxWithBase:(NSString *)base type:(NSString *)type storage:(NSInteger *)storage
{
    [self _loadMaxSoundFileIdxWithBase:base type:type delimiter:@"_" numberFormat:@"%02u" storage:storage];
}

- (void)_loadMaxSoundFileIdxWithBase:(NSString *)base type:(NSString *)type delimiter:(NSString *)delimiter numberFormat:(NSString *)numberFormat storage:(NSInteger *)storage
{
    NSInteger testIdx = 1;
    NSString *fileName = nil;
    NSString *formatString = [NSString stringWithFormat:@"%@%@%@%@",base,type,delimiter,numberFormat];
    while ( ( fileName = [NSString stringWithFormat:formatString,(unsigned)testIdx] ) &&
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

- (CGPoint)_snapLocationOfNode:(EntityNode *)node toSidewalk:(CGPoint)point
{
    CGPoint snappedPoint = point;
    CGFloat halfTextureHeight = node.texture.size.height / 2;
    if ( snappedPoint.y > ( self.gameScreenMap.topSidewalkUpper + halfTextureHeight ) )
        snappedPoint.y = ( self.gameScreenMap.topSidewalkUpper + halfTextureHeight );
    else if ( snappedPoint.y < ( self.gameScreenMap.bottomSidewalkLower + halfTextureHeight ) )
        snappedPoint.y = ( self.gameScreenMap.bottomSidewalkLower + halfTextureHeight );
    
    return snappedPoint;
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if ( self.parentNode.paused )
        return;
    if ( ( arc4random() % 10 ) == 0 )
        [self _addRandomAI];
}

- (void)_addRandomAI
{
    static NSArray *gAITypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gAITypes = @[ [Pedestrian class], [Skater class], [Taxi class] ];
    });
    
    NSUInteger idx = arc4random() % gAITypes.count;
    Class aiClass = gAITypes[idx];
    //NSLog(@"let's add a %@",aiClass);
    EntityNode *ai = [aiClass new];
    [self.parentNode addChild:ai];
    if ( [ai introduceWithFrame:self.frame screenMap:self.gameScreenMap] )
    {
        [self _playSoundNamed:ai.introSoundNames.randomObject];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ( contact.bodyA == contact.bodyB )
        return; // XXX am i doing it wrong?
    //NSLog(@"%@ is in contact with %@",contact.bodyA.node.name,contact.bodyB.node.name);
    
    SKSpriteNode *entityA = (EntityNode *)contact.bodyA.node;
    SKSpriteNode *entityB = (EntityNode *)contact.bodyB.node;
    if ( [entityA isKindOfClass:[EntityNode class]] && [entityB isKindOfClass:[EntityNode class]] )
    {
        if ( ((EntityNode *)entityA).isDead ^((EntityNode *)entityB).isDead )
        {
    #ifdef MYDEBUG
            NSLog(@"ignoring ^dead contact between %@ and %@",entityA,entityB);
    #endif
            return;
        }
        if ( ((EntityNode *)entityA).isAirborne ^ ((EntityNode *)entityB).isAirborne )
        {
    #ifdef MYDEBUG
            NSLog(@"ignoring ^airborne contact between %@ and %@",entityA,entityB);
    #endif
            return;
        }
    }
    
    if ( ! CGRectContainsPoint(self.frame, contact.contactPoint) )
    {
        // http://stackoverflow.com/questions/19162853/horizontally-mirror-a-skspritenode-texture
        // "This broke physics collision detection in iOS 7.1. Very surprising that it would just break."
        // seems to be, disabling "stepping" by xScale = -xScale fixes insta-post-earthquake craziness
        //NSLog(@"XXX ignoring off-screen contact between %@ and %@",entityA,entityB);
        //NSLog(@"a: %@: %0.2f,%0.2f",entityA,entityA.node.position.x,entityA.node.position.y);
        //NSLog(@"b: %@: %0.2f,%0.2f",entityB,entityB.node.position.x,entityB.node.position.y);
        return;
    }
    
    SKPhysicsBody *genericAIPhysics = nil;
    SKPhysicsBody *bouncerPhysics = nil;
    SKPhysicsBody *celebPhysics = nil;
    SKPhysicsBody *groundEffectPhysics = nil;
    
    NSArray *genericAIPrefixes = @[ @"pedestrian-", @"skater-" ];
    
    //NSLog(@"%@ <-!-> %@",contact.bodyA.node.name,contact.bodyB.node.name);
    
    if ( [contact.bodyA.node.name hasPrefix:@"bouncer-"] )
        bouncerPhysics = contact.bodyA;
    else if ([contact.bodyB.node.name hasPrefix:@"bouncer-"] )
        bouncerPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name isEqualToString:@"celeb"] )
        celebPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name isEqualToString:@"celeb"] )
        celebPhysics = contact.bodyB;
    if ( [genericAIPrefixes containsPrefixOfString:contact.bodyA.node.name] )
        genericAIPhysics = contact.bodyA;
    else if ( [genericAIPrefixes containsPrefixOfString:contact.bodyB.node.name] )
        genericAIPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name hasPrefix:@"ground-effect-"] )
        groundEffectPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name hasPrefix:@"ground-effect-"] )
        groundEffectPhysics = contact.bodyB;
    
    if ( bouncerPhysics && genericAIPhysics )
    {
        //[pedPhysics applyImpulse:contact.contactNormal];
        
        if ( self.bouncer.isAirborne )
        {
            //NSLog(@"ignoring airborne player collision");
            return;
        }
        //NSLog(@"%@->%@ %0.2f,%0.2f @ %0.2f,%0.2f",entityA.node.name,entityB.node.name,contact.contactNormal.dx,contact.contactNormal.dy,contact.contactPoint.x,contact.contactPoint.y);
        CGVector normal = contact.contactNormal;
        if ( [entityB.name isEqualToString:@"bouncer-1"] )
        {
            normal.dx = -(normal.dx);
            normal.dy = -(normal.dy);
        }
        [self _genericKillNode:genericAIPhysics.node normal:normal];
    }
    else if ( celebPhysics && genericAIPhysics )
    {
        //NSLog(@"ped->celeb spin %0.2f, %0.2f",contact.contactNormal.dx,contact.contactNormal.dy);
        CGFloat angle = contact.contactNormal.dx > 0 ? 2*M_PI : -(2*M_PI);
        SKAction *action = [SKAction rotateByAngle:angle duration:1];
        [celebPhysics.node runAction:action];
        NSString *sound = [self _randomScream:NO];
        SKAction *scream = [SKAction playSoundFileNamed:sound waitForCompletion:NO];
        [self runAction:scream];
    }
    else if ( genericAIPhysics && groundEffectPhysics )
    {
        //NSLog(@"%@ hit ground effect at %0.2f,%0.2f: %@",pedPhysics.node.name,contact.contactPoint.x,contact.contactPoint.y,groundEffectPhysics.node.name);
        //[self _genericKillNode:pedPhysics.node];
        
        CGFloat angle = contact.contactNormal.dx > 0 ? 2*M_PI : -(2*M_PI);
        SKAction *action = [SKAction rotateByAngle:angle duration:1];
        SKAction *fade = [SKAction fadeOutWithDuration:1];
        [genericAIPhysics.node removeAllActions];
        SKAction *scream = [SKAction playSoundFileNamed:@"child_scream_01.wav" waitForCompletion:NO];
        SKAction *group = [SKAction group:@[ action, fade ]];
        [genericAIPhysics.node runAction:group completion:^{
            [genericAIPhysics.node removeFromParent];
        }];
        [self runAction:scream];
        
        ((EntityNode *)genericAIPhysics.node).isDead = YES;
        [self _handleKill];
        
    }
    //else NSLog(@"some collisions between %@ and %@",contact.bodyA.node.name,contact.bodyB.node.name);
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if ( contact.bodyA == contact.bodyB )
        return; // XXX am i doing it wrong?
    //NSLog(@"%@ is no longer in contact with %@",contact.bodyA.node.name,contact.bodyB.node.name);
}

- (void)_genericKillNode:(SKNode *)node normal:(CGVector)normal
{
    NSTimeInterval flightTime = 1;
    CGFloat notSoRandomX = node.position.x + normal.dx * self.frame.size.width;
    SKAction *flyAway = [SKAction moveTo:CGPointMake(notSoRandomX,FLYAWAY_Y) duration:flightTime];
    SKAction *spin = [SKAction rotateByAngle:4*M_PI duration:flightTime];
    SKAction *shrink = [SKAction scaleBy:0.25 duration:flightTime];
    SKAction *flyAwaySpinAndShrink = [SKAction group:@[ flyAway, spin, shrink ]];
    [node removeAllActions];
    [node runAction:flyAwaySpinAndShrink completion:^{
        SKAction *disappear = [SKAction fadeOutWithDuration:0.25];
        [node runAction:disappear completion:^{
            [node removeFromParent];
        }];
    }];
    
    ((EntityNode *)node).isDead = YES;
    [self _handleKill];
}

- (void)_handleKill
{
    NSDate *lastKillDate = self.lastKillDate;
    self.lastKillDate = [NSDate date];
    
    if ( ! lastKillDate )
        return;
    
    if ( [self.lastKillDate timeIntervalSinceDate:lastKillDate] < COMBO_TIMEOUT )
    {
        self.currentCombo += self.comboMultiplier ? self.comboMultiplier : 1;
        //NSLog(@"combo: %u",self.currentCombo);
        if ( self.currentCombo >= COMBO_THRESHOLD )
        {
            if ( ! self.infoPanelNode )
            {
                NSLog(@"presenting combo node");
                SKSpriteNode *comboNode = [SKSpriteNode spriteNodeWithImageNamed:@"combo-background"];
                comboNode.position = CGPointMake(CGRectGetMidX(self.frame),self.frame.size.height - INFO_PANEL_Y_OFFSET);
                                    //CGPointMake( self.frame.origin.x - INFO_PANEL_X_OFFSET,
                                     //           self.frame.origin.y + INFO_PANEL_Y_OFFSET );
                comboNode.zPosition = INFO_PANEL_Z;
                comboNode.xScale = 1.7;
                comboNode.yScale = 1.7;
                [self.parentNode addChild:comboNode];
                self.infoPanelNode = comboNode;
                
                SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                labelNode.position = CGPointMake( comboNode.position.x + INFO_PANEL_CONTENT_X_OFFSET,
                                                 comboNode.position.y - INFO_PANEL_CONTENT_Y_OFFSET );
                labelNode.zPosition = INFO_PANEL_CONTENT_Z;
                labelNode.fontSize = INFO_PANEL_STANDARD_FONT_SIZE;
                labelNode.fontColor = [UIColor whiteColor];
                labelNode.userData = [NSMutableDictionary dictionary];
                [self.parentNode addChild:labelNode];
                self.infoPanelLabelNode = labelNode;
                
                [self _playSoundNamed:[self _randomSlotSpin]];
            }
            
            self.infoPanelLabelNode.text = [NSString stringWithFormat:@"combo!! %u",(unsigned)self.currentCombo];
            if ( ( self.currentCombo % COMBO_FLASH_THRESHOLD ) == 0 )
            {
                CGFloat currentFlashInterval = COMBO_FLASH_MAX / (float)self.currentCombo / 20;
                dispatch_source_t flashTimer = self.infoPanelLabelNode.userData[@"flashTimer"];
                if ( flashTimer )
                    dispatch_source_cancel(flashTimer);
                
                flashTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
                dispatch_source_set_timer(flashTimer, DISPATCH_TIME_NOW, currentFlashInterval * NSEC_PER_SEC, currentFlashInterval / 2 * NSEC_PER_SEC);
                dispatch_source_set_event_handler(flashTimer, ^{
                    int colorIdx = ((NSNumber *)self.infoPanelLabelNode.userData[@"flashColorIdx"]).intValue;
                    UIColor *nextColor = nil;
                    switch(colorIdx)
                    {
                        case 0:
                            nextColor = [UIColor purpleColor];
                            break;
                        case 1:
                            nextColor = [UIColor blackColor];
                            break;
                        case 2:
                            nextColor = [UIColor whiteColor];
                            break;
                        default:
                            NSLog(@"XXX flashColorIdx");
                            colorIdx = 0;
                            nextColor = [UIColor whiteColor];
                            break;
                    }
                    self.infoPanelLabelNode.fontColor = nextColor;
                    self.infoPanelLabelNode.userData[@"flashColorIdx"] = @(( colorIdx + 1 ) % 3);
                });
                dispatch_resume(flashTimer);
                self.infoPanelLabelNode.userData[@"flashTimer"] = flashTimer;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMBO_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ( [[NSDate date] timeIntervalSinceDate:self.lastKillDate] > COMBO_TIMEOUT )
                {
                    if ( self.currentCombo > 0 )
                    {
                        NSLog(@"removing combo node");
                        self.currentCombo = 0;
                        
                        NSTimeInterval duration = 1.0;
                        SKAction *fade = [SKAction fadeOutWithDuration:duration];
                        SKAction *center = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:duration];
                        SKAction *fadeAndCenter = [SKAction group:@[fade,center]];
                        [@[ self.infoPanelNode, self.infoPanelLabelNode] enumerateObjectsUsingBlock:^(SKNode *obj, NSUInteger idx, BOOL *stop) {
                            [obj runAction:fadeAndCenter completion:^{
                                [self.infoPanelNode removeFromParent];
                                [self.infoPanelLabelNode removeFromParent];
                                self.infoPanelNode = nil;
                            }];
                        }];
                        
                        [self _playSoundNamed:@"slot-machine-cash-out-2.wav"];
                    }
                }
            });
        }
    }
}

@end

@implementation GameScene (RefactorMe)

- (void)_runEarthquakeAtPoint:(CGPoint)point
{
    self.bouncer.isMidAction = YES;
    self.bouncer.currentActionIsInterruptible = NO;
    
    if ( self.bouncer.xScale < 0 )
        self.bouncer.xScale = -(self.bouncer.xScale);
    
    self.bouncer.lastEarthquake = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(EARTHQUAKE_CD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bouncer.lastEarthquake = nil;
    });
    
    CGPoint airPoint = CGPointMake(point.x, ( point.y > self.bouncer.position.y ? point.y : self.bouncer.position.y ) + JUMP_HEIGHT);
    SKAction *flyAction = [SKAction moveTo:airPoint duration:STANDARD_MOVE_DURATION / 1];
    BOOL rightToLeft = self.bouncer.position.x > point.x;
    CGFloat angle = 2 * M_PI * ( rightToLeft ? 1.0 : -1.0 );
    SKAction *spinAction = [SKAction rotateByAngle:angle duration:STANDARD_MOVE_DURATION / 1];
    SKAction *flyAndSpin = [SKAction group:@[ flyAction, spinAction ]];
    self.bouncer.isAirborne = YES;
    SKTexture *defaultTexture = self.bouncer.texture;
    SKTexture *jumpTexture = [SKTexture textureWithImageNamed:@"bouncer-jump-1"];
    jumpTexture.filteringMode = SKTextureFilteringNearest;
    self.bouncer.texture = jumpTexture;
    [self.bouncer runAction:flyAndSpin completion:^{
        SKPhysicsBody *origPhysics = self.bouncer.physicsBody;
        self.bouncer.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:EARTHQUAKE_RADIUS];
        NSTimeInterval landTime = STANDARD_MOVE_DURATION / 3;
        SKAction *landAction = [SKAction moveTo:point duration:landTime];
        //NSTimeInterval activateTime = landTime / 2;
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(activateTime * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        
        SKSpriteNode *earthquake;
        NSArray *earthquakeTextures = [self _texturesForAnimation:@"earthquake" endFrame:4];
        if ( earthquakeTextures )
        {
            SKAction *animateEarthquake = [SKAction animateWithTextures:earthquakeTextures timePerFrame:0.05];
            earthquake = [SKSpriteNode spriteNodeWithTexture:earthquakeTextures[0]];
            earthquake.position = CGPointMake(point.x, point.y + 80);
            earthquake.zPosition = EFFECT_Z;
            earthquake.xScale = 0.75;
            [self.parentNode addChild:earthquake];
            [earthquake runAction:animateEarthquake completion:^{
                [earthquake removeFromParent];
            }];
        }
        
        // XXX this is a hack
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //NSLog(@"eagle is active");
            self.bouncer.isAirborne = NO;
        });
        //NSLog(@"landing");
        [self _playSoundNamed:[self _randomGrunt:YES]];
        self.bouncer.texture = [SKTexture textureWithImageNamed:@"bouncer-jump-2"];
        [self.bouncer runAction:landAction completion:^{
            self.bouncer.texture = defaultTexture;
            //                [self.parentNode.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
            //                    if ( ! [childNode.name hasPrefix:@"bouncer-"]
            //                            && [self.bouncer.node intersectsNode:childNode] )
            //                            NSLog(@"I hit %@",childNode.name);
            //                }];
            //NSLog(@"eagle has landed");
            CGPoint landingEndLoc = earthquake.position;
            self.bouncer.physicsBody = origPhysics;
            [self _playSoundNamed:[self _randomBoom]];
            
            NSUInteger remainingFrames = 6;
            CGFloat timePerFrame = 0.1;
            NSTimeInterval landedDuration = remainingFrames * timePerFrame;
            NSArray *landedTextures = [self _texturesForAnimation:@"earthquake" startFrame:5];
            SKAction *animateLanded = [SKAction animateWithTextures:landedTextures timePerFrame:timePerFrame];
            CGFloat foregroundSpeed = self.foregroundXMovement / self.foregroundXMovementTime;
            SKAction *moveLanded = [SKAction moveByX:foregroundSpeed * landedDuration y:0 duration:landedDuration];
            SKAction *moveAndAnimateLanded = [SKAction group:@[ animateLanded, moveLanded ]];
            SKSpriteNode *landed = [SKSpriteNode spriteNodeWithTexture:landedTextures[0]];
            landed.position = CGPointMake(point.x, point.y + 80);
            landed.zPosition = EFFECT_Z;
            landed.xScale = 0.75;
            [self.parentNode addChild:landed];
            
            NSTimeInterval remnantDuration = 2.0;
            CGFloat groundEffectFPS = 0.2;
            NSUInteger animationRepetitions = remnantDuration / groundEffectFPS;
            
            SKSpriteNode *collisionNode = [SKSpriteNode spriteNodeWithImageNamed:@"debugmask"];
            //CGPoint geCenter = CGPointMake(landedEndLoc.x, landedEndLoc.y - remnant.texture.size.height / 4 / 2);
            //NSLog(@"landed %0.1f,%0.1f, geCenter %0.1f,%0.1f",landedEndLoc.x,landedEndLoc.y,geCenter.x,geCenter.y);
            collisionNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
            collisionNode.name = @"ground-effect-earthquake";
            collisionNode.physicsBody.dynamic = YES;
            collisionNode.physicsBody.affectedByGravity = NO;
            collisionNode.physicsBody.collisionBitMask = self.bouncer.physicsBody.collisionBitMask;//0;
            collisionNode.physicsBody.contactTestBitMask = self.bouncer.physicsBody.contactTestBitMask;//ColliderAI | ColliderCeleb | ColliderBouncer;
            collisionNode.physicsBody.categoryBitMask = self.bouncer.physicsBody.categoryBitMask;//ColliderGroundEffect;
            collisionNode.position = landingEndLoc;
            collisionNode.zPosition = EFFECT_Z;
            collisionNode.xScale = EARTHQUAKE_GROUND_EFFECT_RADIUS / collisionNode.texture.size.width;
            collisionNode.yScale = EARTHQUAKE_GROUND_EFFECT_RADIUS / collisionNode.texture.size.height;
            collisionNode.position = CGPointMake(landingEndLoc.x, landingEndLoc.y - landed.texture.size.height / 3.5);
#ifndef DEBUG_MASKS
            collisionNode.alpha = 0.0;
#endif
            SKAction *moveCollision = [SKAction moveByX:(foregroundSpeed * landedDuration + foregroundSpeed * remnantDuration) y:0 duration:landedDuration + remnantDuration];
            [self.parentNode addChild:collisionNode];
            
            [collisionNode runAction:moveCollision completion:^{
                [collisionNode removeFromParent];
            }];
            
            self.bouncer.isMidAction = NO;
            
            [self.parentNode.children enumerateObjectsUsingBlock:^(SKNode *obj, NSUInteger idx, BOOL *stop) {
                if ( [obj isKindOfClass:[EntityNode class]] )
                {
                    EntityNode *entity = (EntityNode *)obj;
                    if ( ! entity.isFriendly && ! entity.isDead ) // XXX race with collision?
                        entity.isFrightened = YES;
                }
            }];
            
            //SKPhysicsJoint *fixToGround = [SKPhysicsJointFixed jointWithBodyA:<#(SKPhysicsBody *)#> bodyB:<#(SKPhysicsBody *)#> anchor:<#(CGPoint)#>];
            
            [landed runAction:moveAndAnimateLanded completion:^{
                CGPoint landedEndLoc = landed.position;
                [landed removeFromParent];
                
                NSArray *remnantTextures = [self _texturesForAnimation:@"earthquake" startFrame:9];
                SKAction *animateRemnant = [SKAction animateWithTextures:remnantTextures timePerFrame:groundEffectFPS];
                SKAction *repeatRemnant = [SKAction repeatAction:animateRemnant count:animationRepetitions / remnantTextures.count];
                SKAction *moveRemnant = [SKAction moveByX:foregroundSpeed * remnantDuration y:0 duration:remnantDuration];
                SKAction *fadeRemnant = [SKAction fadeOutWithDuration:remnantDuration];
                SKAction *moveAndAnimateRemnant = [SKAction group:@[ repeatRemnant, moveRemnant, fadeRemnant ]];
                
                SKSpriteNode *remnant = [SKSpriteNode spriteNodeWithTexture:remnantTextures[0]];
                remnant.position = landedEndLoc;
                remnant.zPosition = EFFECT_Z;
                remnant.xScale = 0.75;
                [self.parentNode addChild:remnant];
                [remnant runAction:moveAndAnimateRemnant completion:^{
                    //NSLog(@"remnant done...");
                    [remnant removeFromParent];
                }];
            }];
        }];
        
    }];
}

@end

