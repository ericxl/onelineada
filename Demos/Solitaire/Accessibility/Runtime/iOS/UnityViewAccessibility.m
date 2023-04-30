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
    if ( ![UCScene.activeSceneName isEqualToString:@"Game"] )
    {
        return nil;
    }
    NSArray *elements =
    [NSArray ucArrayByIgnoringNilElementsWithCount:8,
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasGameInfo"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasGameControls"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasWin"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasHome"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasPopupMatch"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasPopupOptions"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/UI/CanvasPopupLeaderboard"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAccessibilityNode node:[UCGameObject find:@"/GamePresenter"] withClass:NSClassFromString(@"SolitaireMainGameParentAXElement")]
    ];

    return [elements _axModaledSorted];
}

@end
