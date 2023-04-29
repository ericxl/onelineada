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

@interface _AXGameGlue: NSObject
@end
@implementation _AXGameGlue
+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UnityAXSafeCategoryInstall(@"UnityViewAccessibility");
    });
}
@end

UnityAXDefineSafeCategory(@"UnityView", UnityViewAccessibility)

@implementation UnityViewAccessibility

+ (void)unityAXCategorySetupExistingObjects
{
    Boolean (*axEnabled)(void) = dlsym(dlopen("usr/lib/libAccessibility.dylib", RTLD_NOW), "_AXSApplicationAccessibilityEnabled");
    if ( axEnabled() )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        });
    }
}

// by default Unity engine sets this to YES
- (BOOL)isAccessibilityElement
{
    return NO;
}

// by default Unity engine sets this to direct touch container, so we need to reset
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitNone;
}

- (NSArray *)accessibilityElements
{
    if ( ![UCScene activeSceneIsLoaded] || ![UCScene.activeSceneName isEqualToString:@"Game"] )
    {
        return [super accessibilityElements];
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
