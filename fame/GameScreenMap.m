//
//  GameScreenMap.m
//  fame
//
//  Created by david on 8/11/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameScreenMap.h"

@implementation GameScreenMap

- (CGFloat)bottomSidewalkHeight
{
    return self.bottomSidewalkUpper - self.bottomSidewalkLower;
}

- (CGFloat)topSidewalkHeight
{
    return self.topSidewalkUpper - self.topSidewalkLower;
}

- (CGFloat)groundHeight
{
    return self.topSidewalkUpper - self.bottomSidewalkLower;
}

- (CGFloat)streetHeight
{
    return self.streetUpper - self.streetLower;
}

@end
