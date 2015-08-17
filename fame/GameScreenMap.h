//
//  GameScreenMap.h
//  fame
//
//  Created by david on 8/11/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameScreenMap : NSObject

@property CGRect screenRect;

@property CGRect skyRect;

@property CGFloat belowMountainsY;
@property CGFloat minAltitude;

@property CGFloat controlPanelHeight;

@property CGFloat bottomSidewalkLower;
@property CGFloat bottomSidewalkUpper;
@property (readonly) CGFloat bottomSidewalkHeight;

@property CGFloat streetLower;
@property CGFloat streetUpper;
@property CGFloat streetLeft;
@property CGFloat streetRight;
@property (readonly) CGFloat streetHeight;

@property CGFloat topSidewalkLower;
@property CGFloat topSidewalkUpper;
@property (readonly) CGFloat topSidewalkHeight;

@property (readonly) CGFloat groundHeight;

@property BOOL lane0Occupied;
@property BOOL lane1Occupied;
@property BOOL lane2Occupied;
@property BOOL lane3Occupied;

@end
