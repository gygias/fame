//
//  SpeechBubble.h
//  fame
//
//  Created by david on 8/16/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SpeechBubble : SKSpriteNode

@property NSString *text;
@property NSArray *lines;
@property NSUInteger currentPage;

+ (id)speechBubbleWithText:(NSString *)text origin:(CGPoint)origin;

@end
