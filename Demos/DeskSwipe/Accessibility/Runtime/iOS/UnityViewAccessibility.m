//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnityAXUtils.h"

@implementation UnityViewAccessibility (AXPriv)

- (NSArray *)unityViewAccessibilityElements
{
    if ( ![UCScene.activeSceneName isEqualToString:@"GameplayScene"] )
    {
        return nil;
    }
    NSArray *elements =
    [NSArray ucArrayByIgnoringNilElementsWithCount:7,
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Version Text"] withClass:NSClassFromString(@"UnityAXElementText")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] withClass:NSClassFromString(@"UnityAXElementProgressDisplay")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
         [UnityAccessibilityNode node:[UCGameObject find:@"In-world Canvas/Card Description Display/Card Text"] withClass:NSClassFromString(@"UnityAXElementCard")]
    ];
    return [elements _axModaledSorted];
    
}

@end
