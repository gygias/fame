//
//  Utility.h
//  fame
//
//  Created by david on 8/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSArray (CombobulatedExtensions)

- (BOOL)containsPrefixOfString:(NSString *)string;
- (id)randomObject;

@end

NSString * PointString(CGPoint point);
NSString * RectString(CGRect rect);
NSString * SizeString(CGSize size);

CGPoint CGRectGetMid(CGRect rect);

CGRect ScaledRect(CGRect rect, CGFloat scale);

double Random0Thru1(void);
BOOL RandomBool(void);
BOOL RandomBoolM(int mod);
