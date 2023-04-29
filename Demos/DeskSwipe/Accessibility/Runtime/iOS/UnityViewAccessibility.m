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
    if ( [UCScene activeSceneIsLoaded] && [UCScene.activeSceneName isEqualToString:@"Main"] )
    {
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
    return [super accessibilityElements];
}

@end
