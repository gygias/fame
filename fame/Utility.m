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

- (id)randomObject
{
    if ( self.count > 0 )
        return self[arc4random() % self.count];
    return nil;
}

@end

NSString * PointString(CGPoint point)
{
    return [NSString stringWithFormat:@"(x=%0.2f, y=%0.2f)",point.x,point.y];
}

NSString * RectString(CGRect rect)
{
    return [NSString stringWithFormat:@"%@%@",PointString(rect.origin),SizeString(rect.size)];
}

NSString * SizeString(CGSize size)
{
    return [NSString stringWithFormat:@"[w=%0.2f,h=%0.2f]",size.width,size.height];
}

CGPoint CGRectGetMid(CGRect rect)
{
    return CGPointMake( rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2 );
}

CGRect ScaledRect(CGRect rect, CGFloat scale)
{
    CGFloat quarterX = rect.size.width / ( scale * 2 );
    CGFloat quarterY = rect.size.height / ( scale * 2 );
    return CGRectMake(rect.origin.x - quarterX,
                      rect.origin.y - quarterY,
                      rect.size.width * scale,
                      rect.size.height * scale);
}

double Random0Thru1()
{
    return (double)( arc4random() % 100 ) / 100.0;
}

BOOL RandomBool()
{
    return RandomBoolM(2);
}

BOOL RandomBoolM(int mod)
{
    return ( arc4random() % mod ) == 0;
}