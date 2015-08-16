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
- (void)_runCataclysm;
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
    
    [Sound setScene:self];
    self.gameScreenMap = [GameScreenMap new];
    self.gameScreenMap.screenRect = self.frame;
    CGFloat quarterHeight = ( self.frame.size.height / 4 );
    self.gameScreenMap.skyRect = CGRectMake(self.frame.origin.x,
                                            self.frame.origin.y + self.frame.size.height - quarterHeight,
                                            self.frame.size.width,
                                            quarterHeight);
    self.gameScreenMap.belowMountainsY = MAGICAL_MYSTERY_BELOW_MOUNTAINS;
    
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
    
    CGSize meterSize = [Meter meterSize];
    Meter *angerMeter = [Meter meterWithLabel:@"anger" origin:fuckingBottomLeft xOffset:xOffset yOffset:(meterSize.height / 2) + 1 centered:NO];
    [node addChild:angerMeter];
    self.meter1 = angerMeter;
    
    Meter *zenMeter = [Meter meterWithLabel:@"zen" origin:fuckingBottomLeft xOffset:xOffset yOffset:-(meterSize.height / 2) centered:YES];
    [node addChild:zenMeter];
    self.meter2 = zenMeter;
    
    //[backgroundSprite runAction:rotateForever];
}

NSString *FlashMeterKey = @"flash-meter";

- (void)_angerDelta:(NSInteger)angerDelta
{
    NSInteger startAnger = self.bouncer.anger;
    NSInteger endAnger = startAnger + angerDelta;
    if ( endAnger > MAX_ANGER )
        endAnger = MAX_ANGER;
    if ( endAnger < 0 )
        endAnger = 0;
    
    NSInteger realAngerDelta = endAnger - startAnger;
    //NSLog(@"ad %ld orig %ld net %ld real %ld",angerDelta,origAnger,netAnger,realAngerDelta);
    
    self.bouncer.anger = endAnger;
    
    //NSLog(@"anger %ld + d%ld -> %lu",(long)origAnger,(long)angerDelta,(unsigned long)self.bouncer.anger);
    
    __block int frame = 0;
    NSTimeInterval duration = 0.5;//, frameInterval = 10 / duration, nFrames = duration / frameInterval;
    CGFloat origXScale = self.meter1.fillerNode.xScale;
    CGFloat origX = self.meter1.fillerNode.position.x;
    //NSLog(@"going from %d anger to %d",startAnger,endAnger);
    SKAction *setAction = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double perc = elapsedTime / duration;
        if ( frame < ( perc * 10 ) )
        {
            SKSpriteNode *fillerNode = (SKSpriteNode *)node;
            //NSLog(@"perc %0.2f (%0.2fs / 0.5s)",perc,elapsedTime);
            CGFloat xScaleDelta = perc * (float)realAngerDelta / METER_FILLER_MAX_SCALE;
            CGFloat absoluteDelta = origXScale + xScaleDelta;
            //NSLog(@"drawn %0.2f = origXS %0.2f + xSD %0.2f",absoluteDelta,origXScale,xScaleDelta);
            CGFloat drawnDelta = absoluteDelta;
//            if ( drawnDelta < METER_FILLER_MIN_SCALE )
//            {
//                NSLog(@"min anger!");
//                drawnDelta = METER_FILLER_MIN_SCALE;
//            }
//            if ( drawnDelta > METER_FILLER_MAX_SCALE )
//            {
//                NSLog(@"max anger!");
//                drawnDelta = METER_FILLER_MAX_SCALE;
//            }
            fillerNode.xScale = drawnDelta;
            // accidentally produces interesting grow-from-center effect
            // fillerNode.position = CGPointMake( ( origX + xDelta / 2 ) * (( absoluteDelta - drawnDelta ) / absoluteDelta), fillerNode.position.y );
            CGFloat newX = origX + xScaleDelta/2;
            //NSLog(@"newX : %0.2f",newX);
            //NSLog(@"realA %d absoluteD %0.1f origX %0.1f xScaleDelta %0.1f newX %0.1f",realAngerDelta,absoluteDelta,origX,xScaleDelta,newX);
                fillerNode.position = CGPointMake( newX, fillerNode.position.y );
            frame++;
            
            //NSLog(@"-> xScale = %0.1f + %0.1f",origXScale,xDelta);
        }
    }];
    
    [self.meter1.fillerNode runAction:setAction];
    
    if ( endAnger == MAX_ANGER )
    {
        NSTimeInterval fadeDuration = 0.5;
        SKAction *fadeOut = [SKAction fadeOutWithDuration:fadeDuration];
        SKAction *fadeIn = [SKAction fadeInWithDuration:fadeDuration];
        SKAction *fadeInAndOut = [SKAction sequence:@[fadeOut,fadeIn]];
        SKAction *fadeInAndOutForever = [SKAction repeatActionForever:fadeInAndOut];
        [self.meter1.fillerNode runAction:fadeInAndOutForever withKey:FlashMeterKey];
    }
    else
    {
        [self.meter1.fillerNode removeActionForKey:FlashMeterKey];
        self.meter1.fillerNode.alpha = 1.0;
    }
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
    CGPoint uiKitEndPoint = [recognizer locationInView:self.view];
    CGPoint endPoint = [self convertPointFromView:uiKitEndPoint];
    if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        CGPoint startPoint = [self convertPointFromView:recognizer.currentStartPoint];
        if ( CGRectContainsPoint(ScaledRect(self.bouncer.frame,2.0),startPoint ) )
        {
            [_panRecognizer reset];
            
            if ( CGRectContainsPoint(self.gameScreenMap.skyRect,endPoint) )
            {
                [self _runCataclysm];
            }
            else
            {
                CGPoint velocity = [recognizer velocityInView:self.view];
                CGFloat sumVelocity = ( velocity.x > 0) ? velocity.x : -(velocity.x);
                sumVelocity += ( velocity.y > 0 ) ? velocity.y : -(velocity.y);
                if ( sumVelocity < VELOCITY_THRESHOLD )
                    return;
                //NSLog(@"pan velocity: %0.2f,%0.2f",velocity.x,velocity.y);
                //NSLog(@"pan %@ -> %@",PointString(startPoint),PointString(location));
                [self _playerAction:@"action-4" targetPoint:endPoint];
            }
        }
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
    
    [Sound playSoundNamed:@"no-beep.wav" onNode:theButton];
}

- (void)_playerAction:(NSString *)action targetPoint:(CGPoint)point
{
    if ( self.bouncer.isMidAction
        && ! self.bouncer.currentActionIsInterruptible
        && ! [@[ @"triple-action-1" ] containsObject:action] )
    {
        NSLog(@"ignoring %@ because player is mid non-interruptible action",action);
        return;
    }
    else if ( self.bouncer.isIncapacitated )
        return;
    
    point = [self _snapLocationOfNode:self.bouncer toSidewalk:point];
    NSLog(@"%@: %0.2f,%0.2f",action, point.x, point.y);
    NSString *soundName = nil;
    NSInteger angerDelta = 0;
    
    if ( [action isEqualToString:@"action-1"] )
    {
        if ( self.nextAction1ToSpeechBubble )
        {
            if ( self.advancePageOnTouch )
                [self.speechBubble advancePage];
            else
            {
                SKAction *fadeOut = [SKAction fadeOutWithDuration:0.25];
                [self.speechBubble runAction:fadeOut completion:^{
                    [self.speechBubble removeFromParent];
                    //self.speechBubble = nil;
                }];
            }
            self.advancePageOnTouch = NO;
            self.nextAction1ToSpeechBubble = NO;
            return;
        }
        else if ( self.bouncer.lastMove )
        {
            [self _flashButton:1];
            return;
        }
        [self _walkNode:self.bouncer to:point];
        soundName = [Sound randomGrunt:YES];
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
        if ( self.bouncer.lastCharge )
        {
            [self _flashButton:3];
            return;
        }
        SKAction *moveAction = [SKAction moveTo:point duration:STANDARD_MOVE_DURATION / 5];
        [self.bouncer runAction:moveAction];
        soundName = [Sound randomScream:YES];
        self.bouncer.lastCharge = [NSDate date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CHARGE_CD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.bouncer.lastCharge = nil;
        });
        angerDelta = CHARGE_ANGER;
    }
    else if ( [action isEqualToString:@"double-action-1"] )
    {
        if ( self.celeb.isIncapacitated )
            return;
        [self _walkNode:self.celeb to:self.bouncer.position];
        soundName = @"whistle-1.wav";
    }
    else if ( [action isEqualToString:@"triple-action-1"] )
    {
        [self _togglePause:self.parentNode];
    }
    
    if ( angerDelta )
        [self _angerDelta:angerDelta];
    [self _drawCooldownClock];
    [Sound playSoundNamed:soundName onNode:self.bouncer];
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
        EntityNode *entityNode = (EntityNode *)node;
        if ( pausing )
            [entityNode dispatchActionPause];
        else
            [entityNode dispatchActionResume];
    }
}

NSString *ActionWalkingKey = @"walking";

- (void)_walkNode:(EntityNode *)node to:(CGPoint)point
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
    SKAction *group = [SKAction group:@[ moveAction, customAction ]];
    [node runAction:group withKey:ActionWalkingKey completion:^{
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
    
    if ( ! CGRectContainsPoint(self.frame, self.bouncer.position ) )
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            int idx = 0;
            for ( ; idx < 30; idx++ )
            {
                NSString *fartString = [NSString stringWithFormat:@"fart-%d.wav",( idx % 2 ) + 1];
                [Sound playSoundNamed:fartString onNode:self.bouncer];
                usleep(USEC_PER_SEC * 0.1);
            }
        });
        
        self.bouncer.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) - 200);
    }
    
    [self.parentNode.children enumerateObjectsUsingBlock:^(SKSpriteNode *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[EntityNode class]] )
        {
            EntityNode *node = (EntityNode *)obj;
            if ( ! node.isUI && ! node.isManualZ )
            {
                if ( ! node.isFloored )
                {
                    CGFloat height = self.gameScreenMap.screenRect.size.height;
                    node.zPosition = ( height - node.position.y ) / height * ENTITY_Z_SPAN + ENTITY_Z;
                }
                else
                    node.zPosition = ENTITY_Z;
            }
        }
    }];
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
    if ( [ai introduceWithScreenMap:self.gameScreenMap] )
    {
        [Sound playSoundNamed:ai.introSoundNames.randomObject onNode:ai];
    }
    
    if ( ! self.speechBubble )
    {
        NSString *ORIGINALSPEECH = @"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz, when you hurr, you must not forget to durr, inside the gurr blur. thanks.";
        [self _runSpeechBubbleWithText:ORIGINALSPEECH];
    }
}

NSString *KillScaleKey = @"kill-scale";

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
    SKPhysicsBody *taxiPhysics = nil;
    SKPhysicsBody *groundEffectPhysics = nil;
    
    NSArray *genericAIPrefixes = @[ @"pedestrian-", @"skater-" ];
    
    //NSLog(@"%@ <-!-> %@",contact.bodyA.node.name,contact.bodyB.node.name);
    
    if ( [contact.bodyA.node.name hasPrefix:@"bouncer-"] )
        bouncerPhysics = contact.bodyA;
    else if ([contact.bodyB.node.name hasPrefix:@"bouncer-"] )
        bouncerPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name hasPrefix:@"celeb"] )
        celebPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name hasPrefix:@"celeb"] )
        celebPhysics = contact.bodyB;
    if ( [genericAIPrefixes containsPrefixOfString:contact.bodyA.node.name] )
        genericAIPhysics = contact.bodyA;
    else if ( [genericAIPrefixes containsPrefixOfString:contact.bodyB.node.name] )
        genericAIPhysics = contact.bodyB;
    if ( [contact.bodyA.node.name hasPrefix:@"taxi-"] )
        taxiPhysics = contact.bodyA;
    else if ( [contact.bodyB.node.name hasPrefix:@"taxi-"] )
        taxiPhysics = contact.bodyB;
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
        
        //CGFloat scale = self.bouncer.xScale * 1.1;
        if ( ! [self.bouncer actionForKey:KillScaleKey] )
        {
            CGFloat scale = 1.2;
            CGFloat defaultX = self.bouncer.xScale, defaultY = self.bouncer.yScale;
            NSTimeInterval scaleDuration = 0.05;
            SKAction *scaleUp = [SKAction scaleXBy:scale y:scale duration:scaleDuration];
            SKAction *scaleDown = [SKAction scaleXTo:defaultX y:defaultY duration:scaleDuration];
            SKAction *group = [SKAction sequence:@[scaleUp,scaleDown]];
            [self.bouncer runAction:group withKey:KillScaleKey];
        }
    }
    else if ( celebPhysics && genericAIPhysics )
    {
        EntityNode *celeb = (EntityNode *)celebPhysics.node;
        if ( ! celeb.isFloored )
        {
            //NSLog(@"ped->celeb spin %0.2f, %0.2f",contact.contactNormal.dx,contact.contactNormal.dy);
            CGFloat angle = contact.contactNormal.dx > 0 ? 2*M_PI : -(2*M_PI);
            SKAction *action = [SKAction rotateByAngle:angle duration:1];
            [celeb runAction:action];
            NSString *sound = [Sound randomScream:NO];
            SKAction *scream = [SKAction playSoundFileNamed:sound waitForCompletion:NO];
            [self runAction:scream completion:^{
                [celeb runAction:[SKAction rotateToAngle:0 duration:0.0]];
            }];
        }
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
    else if ( bouncerPhysics && taxiPhysics )
    {
        NSLog(@"bouncer vs taxi");
        [self _runOverNode:self.bouncer withNode:(EntityNode *)taxiPhysics.node];
        [self _angerDelta:RUN_OVER_ANGER];
        [Sound playSoundNamed:@"fart-1.wav" onNode:self.bouncer];
    }
    else if ( celebPhysics && taxiPhysics )
    {
        NSLog(@"celeb vs taxi");
        [self _runOverNode:self.celeb withNode:(EntityNode *)taxiPhysics.node];
        [Sound playSoundNamed:@"fart-2.wav" onNode:self.celeb];
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
    
    [Sound playSoundNamed:@"pop-1.wav" onNode:node];
    ((EntityNode *)node).isDead = YES;
    [self _handleKill];
    
}

- (void)_runOverNode:(EntityNode *)node withNode:(EntityNode *)attacker
{
    BOOL wasMoving = [node actionForKey:ActionWalkingKey] != nil;
    
    [node removeAllActions];
    [node dispatchActionPause];
    
    NSLog(@"%@ %@ moving",node.name, wasMoving ? @"was" : @"wasn't");
    CGPoint point = wasMoving ? [node midpointToNode:attacker] : node.position;
    [node runAction:[SKAction moveTo:point duration:0.0]];
    
    SKSpriteNode *tireTread = [SKSpriteNode spriteNodeWithImageNamed:@"tire-tread-1"];
    tireTread.zPosition = ENTITY_Z + ENTITY_Z_INC;
    tireTread.xScale = node.xScale;
    tireTread.yScale = node.yScale;
    tireTread.position = point;
    [self.parentNode addChild:tireTread];
    
    node.zPosition = ENTITY_Z;
    node.isFloored = YES;
    
    BOOL leftToRight = ( arc4random() % 2 ) == 0;
    //node.zRotation =
    CGFloat radians = ( leftToRight ? ( M_PI_4*3 - M_PI_4 ) : ( M_PI*7 - M_PI_4 * 5 ) ) * (double)( ( arc4random() % 100 ) ) / 100.0;
    [node runAction:[SKAction rotateToAngle:radians duration:0.0]];
    node.isIncapacitated = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        node.isIncapacitated = NO;
        node.isFloored = YES;
        [node dispatchActionResume];
        //node.zRotation = 0;
        [node runAction:[SKAction rotateToAngle:0.0 duration:0.0]];
        [tireTread removeFromParent];
    });
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
            if ( ! self.comboBoxNode.parent )
            {
                NSLog(@"presenting combo node");
                ComboBox *comboBox = [ComboBox new];
                comboBox.comboEndedHandler = ^(ComboBox *comboBox) {
                    self.currentCombo = 0;
                };
                [comboBox introduceWithScreenMap:self.gameScreenMap];
                [self.parentNode addChild:comboBox];
                self.comboBoxNode = comboBox;
                
                [Sound playSoundNamed:[Sound randomSlotSpin] onNode:self.comboBoxNode];
            }
            
            self.comboBoxNode.combo = self.currentCombo;
        }
    }
}

- (void)_runSpeechBubbleWithText:(NSString *)text
{
    CGPoint origin = CGPointMake(CGRectGetMidX(self.gameScreenMap.screenRect),self.gameScreenMap.screenRect.size.height + INFO_PANEL_Y_OFFSET * 2 + 1);
    SKSpriteNode *bouncerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"bouncer-1"];
    bouncerSprite.texture.filteringMode = SKTextureFilteringNearest;
    SpeechBubble *speechBubble = [SpeechBubble speechBubbleWithText:text
                                                             origin:origin
                                                          imageNode:bouncerSprite];
    [self.parentNode addChild:speechBubble];
    [speechBubble animate];
    speechBubble.pageFinishedAnimatingHandler = ^(SpeechBubble *speechBubble, BOOL morePages) {
        self.advancePageOnTouch = morePages;
        self.nextAction1ToSpeechBubble = YES;
    };
    
    if ( self.speechBubble )
        [self.speechBubble removeFromParent];
    
    self.speechBubble = speechBubble;
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
        [Sound playSoundNamed:[Sound randomGrunt:YES] onNode:self.bouncer];
        self.bouncer.texture = [SKTexture textureWithImageNamed:@"bouncer-jump-2"];
        self.bouncer.texture.filteringMode = SKTextureFilteringNearest;
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
            [Sound playSoundNamed:[Sound randomBoom] onNode:self.bouncer];
            
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

- (void)_runCataclysm
{
    self.bouncer.isMidAction = YES;
    self.bouncer.currentActionIsInterruptible = NO;
    self.bouncer.isAirborne = YES;
    self.bouncer.isManualZ = YES;
    [self.bouncer dispatchActionPause];
    
    CGPoint origLocation = self.bouncer.position;
    CGFloat defaultXScale = self.bouncer.xScale, defaultYScale = self.bouncer.yScale;
    CGFloat origZPosition = self.bouncer.zPosition;
    
    NSTimeInterval flyTowardDuration = 0.33;
    SKAction *upright = [SKAction rotateToAngle:0 duration:0.0];
    SKAction *flyToward = [SKAction scaleXBy:50.0 y:50.0 duration:flyTowardDuration];
    SKAction *flyMid = [SKAction moveTo:CGRectGetMid(self.gameScreenMap.screenRect) duration:flyTowardDuration];
    SKAction *fade = [SKAction fadeOutWithDuration:flyTowardDuration];
    fade.timingMode = SKActionTimingEaseIn;
    SKAction *playFlybyAndFadeCeleb = [SKAction runBlock:^{
        [Sound playSoundNamed:@"flyby-1.wav" onNode:self.bouncer];
        
        SKAction *fadeCeleb = [SKAction fadeOutWithDuration:1.0];
        self.celeb.isAirborne = YES;
        [self.celeb dispatchActionPause];
        [self.celeb runAction:fadeCeleb];
    }];
    //SKAction *fadeIn = [SKAction fadeInWithDuration:0.0];
    SKAction *flyTowardMid = [SKAction group:@[flyToward,flyMid,fade,playFlybyAndFadeCeleb]];
    SKAction *disappear = [SKAction runBlock:^{
        self.bouncer.zPosition = BEHIND_BACKGROUND_Z;
        self.bouncer.alpha = 1.0;
        //NSLog(@"hid...");
        [Sound playSoundNamed:@"chant-1.wav" onNode:self.bouncer];
    }];
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *peekScale = [SKAction scaleXTo:10.0 y:10.0 duration:0.0];
    CGFloat peekHeight = self.bouncer.size.height * 1.4;
    SKAction *hide = [SKAction moveToY:self.gameScreenMap.belowMountainsY duration:0.0];
    NSTimeInterval peekDuration = 5.0;
    SKAction *peek = [SKAction moveToY:self.gameScreenMap.belowMountainsY + peekHeight duration:peekDuration];
    SKAction *leer = [SKAction waitForDuration:1.5];
    SKAction *playExplosion = [SKAction runBlock:^{
        [Sound playSoundNamed:@"explosion-1.wav" onNode:self.bouncer];
    }];
    SKAction *flyAway = [SKAction moveToY:self.gameScreenMap.screenRect.origin.y + self.gameScreenMap.screenRect.size.height + self.bouncer.size.height*3
                                 duration:0.5];
    SKAction *disappearNow = [SKAction fadeOutWithDuration:0.0];
    SKAction *flyAwayAndDisappear = [SKAction sequence:@[ flyAway, disappearNow ]];
    NSTimeInterval colorizeDuration = 1.0;
    __block NSMutableArray *dyingNodes = [NSMutableArray new];
    SKAction *paintWorldRed = [SKAction runBlock:^{
        SKAction *paint = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1.0 duration:colorizeDuration];
        [self.parentNode.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
            EntityNode *entityNode = nil;
            if ( [childNode isKindOfClass:[EntityNode class]] )
            {
                entityNode = (EntityNode *)childNode;
                if ( ! entityNode.isFriendly )
                {
                    [entityNode dispatchActionPause];
                    [entityNode removeAllActions];
                    entityNode.isDead = YES;
                }
            }
            
            [childNode runAction:paint completion:^{
                if ( ! entityNode || entityNode.isFriendly )
                {
                    // colorize is not reversible
                    SKAction *unpaint = [SKAction colorizeWithColor:[UIColor clearColor] colorBlendFactor:0.0 duration:colorizeDuration];
                    [childNode runAction:unpaint];
                }
                else
                    [dyingNodes addObject:entityNode];
            }];
        }];
    }];
    SKAction *explosionAndRed = [SKAction group:@[playExplosion, paintWorldRed]];
    //SKAction *leerSomeMore = leer;
    SKAction *sequence = [SKAction sequence:@[ upright, flyTowardMid, peekScale, disappear, hide, wait, peek, leer, flyAwayAndDisappear, explosionAndRed/*, leerSomeMore*/ ]];
    [self.bouncer runAction:sequence withKey:@"lol" completion:^{
        NSLog(@"lol completed");
        SKAction *playTeleport = [SKAction runBlock:^{
            [Sound playSoundNamed:@"teleport-1.wav" onNode:self.bouncer];
        }];
        NSTimeInterval teleportDuration = 1.5;
        SKAction *fadeOut = [SKAction fadeOutWithDuration:teleportDuration];
        SKAction *moveBack = [SKAction moveTo:origLocation duration:0.0];
        SKAction *scaleBack = [SKAction scaleXTo:defaultXScale y:defaultYScale duration:0.0];
        SKAction *changeZ = [SKAction runBlock:^{
            [self.bouncer dispatchActionResume];
            self.bouncer.zPosition = origZPosition;
        }];
        NSLog(@"returning to %@ (%0.2fxs,%0.2fys)",PointString(origLocation),defaultXScale,defaultYScale);
        SKAction *fadeIn = [SKAction fadeInWithDuration:teleportDuration];
        SKAction *fadeDead = [SKAction runBlock:^{
            SKAction *fade = [SKAction fadeOutWithDuration:teleportDuration];
            [dyingNodes enumerateObjectsUsingBlock:^(EntityNode *obj, NSUInteger idx, BOOL *stop) {
                [obj runAction:fade completion:^{
                    [obj removeFromParent];
                }];
            }];
        }];
        SKAction *fadeInCeleb = [SKAction runBlock:^{
            [self.celeb runAction:fadeIn completion:^{
                self.celeb.isAirborne = NO;
                self.celeb.isManualZ = NO;
                [self.celeb dispatchActionResume];
            }];
        }];
        SKAction *fadeInAndFadeOutDead = [SKAction group:@[ fadeIn, fadeDead, fadeInCeleb ]];
        SKAction *sequence = [SKAction sequence:@[ playTeleport,fadeOut,moveBack,scaleBack,changeZ,fadeInAndFadeOutDead ]];
        [self.bouncer runAction:sequence withKey:@"return" completion:^{
            self.bouncer.isMidAction = NO;
            self.bouncer.isAirborne = NO;
            self.bouncer.isManualZ = NO;
            
            [self _runSpeechBubbleWithText:@"that'll show them."];
        }];
    }];
}

@end

