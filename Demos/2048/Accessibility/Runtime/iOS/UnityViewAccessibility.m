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
    if ( ![UCScene.activeSceneName isEqualToString:@"SampleScene"] )
    {
        return nil;
    }
    NSArray *elements =
    [NSArray ucArrayByIgnoringNilElementsWithCount:4,
         [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/Scores/Score"] withClass:NSClassFromString(@"NumberSwiperScoreElement")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/Scores/Best"] withClass:NSClassFromString(@"NumberSwiperScoreElement")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/CreateNewGameButton"] withClass:NSClassFromString(@"NumberSwiperButtonElement")],
         [UnityAccessibilityNode node:[UCGameObject find:@"/Canvas/Board"] withClass:NSClassFromString(@"NumberSwiperBoardElement")]
    ];
    return [elements _axModaledSorted];
}

@end
