//
//  SpeechBubble.h
//  fame
//
//  Created by david on 8/16/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SpeechBubble : SKSpriteNode
{
    NSUInteger _charIdx;
    NSUInteger _lineIdx;
    dispatch_source_t _animateTimer;
    NSObject *_currentSound;
}

@property NSString *text;
@property NSArray *lines;
@property NSUInteger currentPage;
@property SKSpriteNode *imageNode;

+ (id)speechBubbleWithText:(NSString *)text origin:(CGPoint)origin imageNode:(SKSpriteNode *)imageNode;

typedef void (^PageFinishedAnimatingHandler)(SpeechBubble*,BOOL);
@property (copy) PageFinishedAnimatingHandler pageFinishedAnimatingHandler;
- (void)animate;
- (void)advancePage;

@end
