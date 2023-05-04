//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "UnityAXUtils.h"

@implementation UnityViewAccessibility (AXPriv)

- (NSArray *)unityViewAccessibilityElements
{
    if ( ![UCScene.activeSceneName isEqualToString:@"Wordle"] )
    {
        return nil;
    }
    NSArray *elements =
    [NSArray ucArrayByIgnoringNilElementsWithCount:2,
     [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/Board"] withClass:NSClassFromString(@"WordleBoardAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/Keyboard"] withClass:NSClassFromString(@"WordleKeyboardAXElement")]
    ];

    return [elements _axModaledSorted];
}

@end
