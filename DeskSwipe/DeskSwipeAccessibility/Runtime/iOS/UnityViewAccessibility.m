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
    if ( [UEOUnityEngineScene activeSceneIsLoaded] && [UEOUnityEngineScene.activeSceneName isEqualToString:@"Main"] )
    {
        NSArray *elements =
        [NSArray ueoArrayByIgnoringNilElementsWithCount:7,
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] withClass:NSClassFromString(@"UnityAXElementText")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] withClass:NSClassFromString(@"UnityAXElementProgressDisplay")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] withClass:NSClassFromString(@"UnityAXElementBarGroup")],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"In-world Canvas/Card Description Display/Card Text"] withClass:NSClassFromString(@"UnityAXElementCard")]
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
    return [super accessibilityElements];
}

@end
