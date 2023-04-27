//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

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
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementText.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementProgressDisplay.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementBarGroup.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementBarGroup.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementBarGroup.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementBarGroup.class];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] addComponent:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] accessibleWithClass:UnityAXElementCard.class];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self);
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
    NSArray *nodeComponents = [[UEOUnityEngineObject findObjectsOfType:@"UnityObjCRuntime.UnityObjCRuntimeBehaviour"] _ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineObject * _Nonnull item, NSUInteger index) {
        return [item isKindOfClass:UEOUnityObjCRuntimeBehaviour.class] && [(UEOUnityObjCRuntimeBehaviour *)item createAXElement];
    }];
    NSArray *nodes = [nodeComponents _ueoFlatMapedObjectsWithBlock:^id _Nonnull(id  _Nonnull obj) {
        return [UnityAXElement nodeFrom:(UEOUnityObjCRuntimeBehaviour *)obj];
    }];
    id modal = [nodes _unityAccessibilityModalElement];
    if ( modal != nil )
    {
        return @[modal];
    }
    else
    {
        return [nodes _unityAccessibilitySorted];
    }
}

@end
