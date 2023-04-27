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
    if ( ![UEOUnityEngineScene activeSceneIsLoaded] || ![UEOUnityEngineScene.activeSceneName isEqualToString:@"Game"] )
    {
        return [super accessibilityElements];
    }
    NSArray *elements =
    [NSArray ueoArrayByIgnoringNilElementsWithCount:8,
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGameInfo"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasGameControls"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasWin"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasHome"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasPopupMatch"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasPopupOptions"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/UI/CanvasPopupLeaderboard"] withClass:NSClassFromString(@"SolitaireCanvasGroupAXElement")],
     [UnityAXElement node:[UEOUnityEngineGameObject find:@"/GamePresenter"] withClass:NSClassFromString(@"SolitaireMainGameParentAXElement")]
    ];

    return [elements _axModaledSorted];
}

@end
