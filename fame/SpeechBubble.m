//
//  SpeechBubble.m
//  fame
//
//  Created by david on 8/16/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpeechBubble.h"

#import "Fame.h"

#define SPEECH_LINE_HEIGHT 7.0
#define SPEECH_TEXT_Y_INSET 3.0
#define SPEECH_TEXT_X_INSET 2.0
#define LINES_PER_PAGE 3
#define CHARS_PER_LINE 58

@implementation SpeechBubble

+ (id)speechBubbleWithText:(NSString *)text origin:(CGPoint)origin
{
    SpeechBubble *speechBubble = [[SpeechBubble alloc] initWithImageNamed:@"speech-bubble-1"];
    speechBubble.texture.filteringMode = SKTextureFilteringNearest;
    speechBubble.zPosition = INFO_PANEL_Z;
    speechBubble.position = origin;
    speechBubble.xScale = 5.0;
    speechBubble.yScale = 2.0;
    speechBubble.text = text;
    
    NSLog(@"speech bubble has size %@",SizeString(speechBubble.size));
    
    [speechBubble _paginate];
    
    CGPoint lineOrigin = CGPointMake(0,//-(speechBubble.texture.size.width / 2 + 3),
                                     SPEECH_LINE_HEIGHT - SPEECH_TEXT_Y_INSET);
    int idx = 0;
    for ( ; idx < speechBubble.lines.count && idx < LINES_PER_PAGE; idx++ )
    {
        NSString *line = speechBubble.lines[idx];
        NSLog(@"inserting '%@'",line);
        CGFloat halfWidth = speechBubble.size.width / 2;
        CGFloat xOffsetPerc = 1 - ((float)line.length / (float)CHARS_PER_LINE);
        lineOrigin.x = -( xOffsetPerc * halfWidth ) + SPEECH_TEXT_X_INSET;
        NSLog(@"%d chars: %0.2f -> %0.2f",line.length,xOffsetPerc,lineOrigin.x);
        SKLabelNode *label = [speechBubble _labelNodeWithText:line origin:lineOrigin];
        label.name = [label.name stringByAppendingFormat:@"-%d",idx];
        lineOrigin.y -= SPEECH_LINE_HEIGHT;
        [speechBubble addChild:label];
    }
    
    
    return speechBubble;
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
    return label;
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
