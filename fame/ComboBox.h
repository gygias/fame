//
//  ComboBox.h
//  fame
//
//  Created by david on 8/15/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EntityNode.h"

@interface ComboBox : EntityNode
{
    dispatch_source_t _flashTimer;
    NSDate *_lastUpdate;
    NSUInteger _combo;
    CGPoint _endPoint;
}

typedef void (^ComboEndedHandler)(ComboBox*);
@property (copy) ComboEndedHandler comboEndedHandler;
@property NSTimeInterval comboDuration;
@property (nonatomic) NSUInteger combo;

@end
