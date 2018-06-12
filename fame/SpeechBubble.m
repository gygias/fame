//
//  SpeechBubble.m
//  fame
//
//  Created by david on 8/16/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpeechBubble.h"

#import "Fame.h"

#define SPEECH_LINE_HEIGHT 6.0
#define SPEECH_TEXT_Y_INSET 5.0
#define SPEECH_X_INSET 10.0
#define SPEECH_IMAGE_X -35.0
#define SPEECH_IMAGE_Y 0
#define SPEECH_TEXT_X_INSET SPEECH_X_INSET
#define LINES_PER_PAGE 3
#define CHARS_PER_LINE 50

@implementation SpeechBubble

+ (id)speechBubbleWithText:(NSString *)text origin:(CGPoint)origin imageNode:(SKSpriteNode *)imageNode
{
    SpeechBubble *speechBubble = [[SpeechBubble alloc] initWithImageNamed:@"speech-bubble-1"];
    speechBubble.texture.filteringMode = SKTextureFilteringNearest;
    speechBubble.zPosition = INFO_PANEL_Z;
    speechBubble.position = origin;
    speechBubble.xScale = 5.0;
    speechBubble.yScale = 2.5;
    speechBubble.userInteractionEnabled = YES;
    speechBubble.text = text;
    
    if ( imageNode )
    {
        speechBubble.imageNode = imageNode;
        imageNode.name = @"speaker-image";
        imageNode.zPosition = INFO_PANEL_CONTENT_Z;
        imageNode.position = CGPointMake(SPEECH_IMAGE_X, SPEECH_IMAGE_Y);
        imageNode.xScale = 1 / speechBubble.xScale;
        imageNode.yScale = 1 / speechBubble.yScale;
        [speechBubble addChild:imageNode];
    }
    
    NSLog(@"speech bubble has size %@",SizeString(speechBubble.size));
    
    [speechBubble _paginate];
    
//    int idx = 0;
//    for ( ; idx < speechBubble.lines.count && idx < LINES_PER_PAGE; idx++ )
//    {
//        NSString *line = speechBubble.lines[idx];
//        CGPoint lineOrigin = CGPointMake( [speechBubble _xOriginForTextWithLength:line.length], [speechBubble _yOriginForLineNumber:idx] );
//        SKLabelNode *label = [speechBubble _labelNodeWithText:line origin:lineOrigin];
//        label.name = [label.name stringByAppendingFormat:@"-%d",idx];
//        [speechBubble addChild:label];
//    }    
    
    return speechBubble;
}

typedef void (^AnimateBlock)(void);
- (AnimateBlock)_animateBlock
{
    return ^(){
        NSString *animatingLineKey = @"animating-line";
        NSString *animatedLineKey = @"animated-line";
        NSUInteger lineIdx = self->_lineIdx + self.currentPage * LINES_PER_PAGE;
        
        if ( lineIdx == self.lines.count )
        {
            [self _stopAnimation];
            if ( self.pageFinishedAnimatingHandler )
                self.pageFinishedAnimatingHandler(self, NO);
            return;
        }
        
        NSString *theLine = self.lines[lineIdx];
        if ( [theLine isEqualToString:@"f"] )
            NSLog(@"??");
        
        if ( self->_charIdx == theLine.length )
        {
            self->_lineIdx++;
            if ( self->_lineIdx == ( LINES_PER_PAGE * self.currentPage + LINES_PER_PAGE ) )
            {
                //NSLog(@"end of page...?");
                [self _stopAnimation];
                //self.currentPage++;
                //_lineIdx = 0;
                BOOL moreToCome = ( self.currentPage + 1 ) < self.lines.count;
                if ( moreToCome )
                    [Sound playSoundNamed:@"carriage-return-1.wav" onNode:self];
                if ( self.pageFinishedAnimatingHandler )
                    self.pageFinishedAnimatingHandler(self, moreToCome);
                return;
            }
            else if ( self->_lineIdx == self.lines.count )
            {
                [self _stopAnimation];
                if ( self.pageFinishedAnimatingHandler )
                    self.pageFinishedAnimatingHandler(self,NO);
                return;
            }
            theLine = self.lines[self->_lineIdx];
            self->_charIdx = 0;
            
            [self.children enumerateObjectsUsingBlock:^(SKNode *child, NSUInteger idx, BOOL *stop) {
                child.name = animatedLineKey;
            }];
            NSLog(@"new line");
        }
        
        NSString *drawnPortion = [theLine substringToIndex:++self->_charIdx];
        SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:animatingLineKey];
        if ( ! label )
        {
            NSLog(@"new node");
            CGPoint lineOrigin = CGPointMake( [self _xOriginForTextWithLength:theLine.length], [self _yOriginForLineNumber:self->_lineIdx] );
            label = [self _labelNodeWithText:drawnPortion origin:lineOrigin];
            label.name = animatingLineKey;
            [self addChild:label];
        }
        else
            label.text = drawnPortion;
        //NSLog(@"[%d,%d]\n '%@'",lineIdx,_charIdx,drawnPortion);
        //_charIdx++;
    };
}

- (void)animate
{
    [self _animateFromChar:0 line:0 page:0];
}

- (void)_animateFromChar:(NSUInteger)charIdx line:(NSUInteger)lineIdx page:(NSUInteger)pageIdx
{
    _charIdx = charIdx;
    _lineIdx = lineIdx;
    _currentPage = pageIdx;
    
    if ( pageIdx == 0 && lineIdx == 0 && charIdx == 0 )
    {
        [self.children enumerateObjectsUsingBlock:^(SKNode *child, NSUInteger idx, BOOL *stop) {
            if ( [child isKindOfClass:[SKLabelNode class]] )
                [child removeFromParent];
        }];
        [self _startAnimating];
    }
    else
    {
        SKAction *fadeExistingOut = [SKAction fadeOutWithDuration:0.25];
        [self.children enumerateObjectsUsingBlock:^(SKNode *childNode, NSUInteger idx, BOOL *stop) {
            if ( [childNode isKindOfClass:[SKLabelNode class]] )
            {
                [childNode runAction:fadeExistingOut completion:^{
                    if ( self.children.count == ( self.imageNode ? 2 : 1 ) )
                        [self _startAnimating];
                    [childNode removeFromParent];
                }];
            }
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touched speech?");
    if ( ( ( self.currentPage + 1 ) * LINES_PER_PAGE ) < self.lines.count )
        [self _animateFromChar:0 line:0 page:self.currentPage + 1];
    else
    {
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.25];
        [self runAction:fadeOut completion:^{
            [self removeFromParent];
        }];
    }
    
}

- (void)advancePage
{
    [self _animateFromChar:0 line:0 page:self.currentPage];
}

- (void)_startAnimating
{
    _currentSound = [Sound playStoppableSoundNamed:@"typewriter-1.wav" onNode:self];
    
    NSTimeInterval charDuration = 0.01;
    _animateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_animateTimer, DISPATCH_TIME_NOW, charDuration * NSEC_PER_SEC, charDuration * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_animateTimer, [self _animateBlock]);
    dispatch_resume(_animateTimer);
}

- (void)_stopAnimation
{
    if ( _animateTimer )
    {
        dispatch_source_cancel(_animateTimer);
        _animateTimer = nil;
    }
    if ( _currentSound )
    {
        [Sound stopSound:_currentSound];
        _currentSound = nil;
    }
}

- (void)removeFromParent
{
    [self _stopAnimation];
    [super removeFromParent];
}

- (SKLabelNode *)_labelNodeWithText:(NSString *)text origin:(CGPoint)origin
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.name = @"speech-bubble-label";
    label.position = origin;
    label.zPosition = INFO_PANEL_CONTENT_Z;
    label.fontSize = SPEECH_BUBBLE_FONT_SIZE;
    label.fontColor = [UIColor blackColor];
    label.userData = [NSMutableDictionary dictionary];
    label.text = text;
    label.xScale = 1 / self.xScale;
    label.yScale = 1 / self.yScale;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    return label;
}

- (CGFloat)_yOriginForLineNumber:(NSUInteger)lineNumber
{
    return -( (CGFloat)lineNumber * SPEECH_LINE_HEIGHT ) + SPEECH_TEXT_Y_INSET;
}

- (CGFloat)_xOriginForTextWithLength:(NSUInteger)length
{
    //CGFloat halfWidth = self.size.width / 2;
    //CGFloat xOffsetPerc = 1 - ((float)length / (float)CHARS_PER_LINE);
    //return -halfWidth + SPEECH_TEXT_X_INSET;
    //NSLog(@"%d chars: %0.2f -> %0.2f",line.length,xOffsetPerc,lineOrigin.x);
    return -40.0 + SPEECH_TEXT_X_INSET;
}

- (void)_paginate
{
    NSString *delimiter = @" ";
    NSMutableArray *words = [[self.text componentsSeparatedByString:delimiter] mutableCopy];
    int wordIdx = 0;
    
    NSMutableArray *lines = [NSMutableArray new];
    
    NSString *lineString = @"";
    
    for ( ; wordIdx < words.count; )
    {
        NSString *thisWord = words[wordIdx];
        if ( thisWord.length > CHARS_PER_LINE )
        {
            NSUInteger clipIdx = CHARS_PER_LINE - 1 - lineString.length;
            NSString *clippedWord = [thisWord substringToIndex:clipIdx];
            NSString *remainder = [thisWord substringFromIndex:clipIdx];
            NSLog(@"clipped '%@'",clippedWord);
            NSLog(@"remainder '%@'",remainder);
            [words replaceObjectAtIndex:wordIdx withObject:remainder];
            [lines addObject:clippedWord];
            lineString = @"";
        }
        else if ( ( lineString.length + thisWord.length + delimiter.length ) < CHARS_PER_LINE )
        {
            lineString = [lineString stringByAppendingFormat:@"%@%@", (lineString.length > 0 ? delimiter : @""),thisWord];
            wordIdx++;
        }
        else
        {
            [lines addObject:lineString];
            lineString = @"";
        }
    }
    if ( lineString.length )
        [lines addObject:lineString];
    
    self.lines = lines;
    
    NSLog(@"%@=>lines:\n%@",self.text,lines);
}

@end
