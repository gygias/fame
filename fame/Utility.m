//
//  Utility.m
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Utility.h"

@implementation NSArray (CombobulatedExtensions)

- (BOOL)containsPrefixOfString:(NSString *)string
{
    __block BOOL contains = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[NSString class]] )
        {
            if ( [string hasPrefix:obj] )
            {
                contains = YES;
                *stop = YES;
            }
        }
    }];
    
    return contains;
}

@end
