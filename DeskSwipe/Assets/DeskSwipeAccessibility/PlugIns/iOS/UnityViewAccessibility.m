//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "UnityEngineObjC.h"
#import "UnityAXElement.h"
#import "UnityAXElementText.h"
#import "UnityAXElementProgressDisplay.h"
#import "UnityAXElementBarGroup.h"
#import "UnityAXElementCard.h"

ObjCDefineSafeOverride(@"UnityView", UnityViewAccessibility)

@implementation NSArray (UnityAccessibilityAdditions)
- (id)_unityAccessibilityModalElement
{
    for (id obj in self)
    {
        if ([obj accessibilityViewIsModal])
        {
            return obj;
        }
    }
    return nil;
}
- (nullable NSArray *)_unityAccessibilitySorted
{
    return [self sortedArrayUsingSelector:NSSelectorFromString(@"accessibilityCompareGeometry:")];
}
@end

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
        [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] withClass:UnityAXElementText.class];
        NSArray *elements =
        [NSArray _ueoArrayByIgnoringNilElementsWithCount:7,
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] withClass:UnityAXElementText.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] withClass:UnityAXElementProgressDisplay.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] withClass:UnityAXElementBarGroup.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] withClass:UnityAXElementBarGroup.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] withClass:UnityAXElementBarGroup.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] withClass:UnityAXElementBarGroup.class],
             [UnityAXElement node:[UEOUnityEngineGameObject find:@"In-world Canvas/Card Description Display/Card Text"] withClass:UnityAXElementCard.class]
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
