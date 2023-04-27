//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "UnityAccessibility.h"

ObjCDefineSafeOverride(@"UnityView", UnityViewAccessibility)

@implementation UnityViewAccessibility

+ (void)objCOverrideSetupExistingObjects
{
    Boolean (*axEnabled)(void) = dlsym(dlopen("usr/lib/libAccessibility.dylib", RTLD_NOW), "_AXSApplicationAccessibilityEnabled");
    if ( axEnabled() )
    {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
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
    if ( ![UEOUnityEngineScene activeSceneIsLoaded] || ![UEOUnityEngineScene.activeSceneName isEqualToString:@"Game"] )
    {
        return [super accessibilityElements];
    }
    NSArray *elements =
    [NSArray ueoArrayByIgnoringNilElementsWithCount:4,
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGameInfo"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGameControls"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasWin"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasHome"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")]
//     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGamePopupMatch"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
//     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGamePopupOptions"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
//     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGamePopupLeaderboard"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
    ];

    id modal = [elements _unityAccessibilityModalElement];
    if ( modal != nil )
    {
        return @[modal];
    }
    else
    {
        return [elements _unityAccessibilitySorted];
    }
}

@end
