//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AppleAccessibilitySafeOverride.h"

#import "UnityEngineObjC.h"
#import "UnityAccessibilityNode.h"

AppleAccessibilityDefineSafeOverride(@"UnityView", UnityViewAccessibility)

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

// by default Unity engine sets this to YES
- (BOOL)isAccessibilityElement
{
//    if ( [AppleAccessibilityRuntime.sharedInstance isAccessibilityEnabledForUnityView:self] )
//    {
//        return NO;
//    }
//    return [super isAccessibilityElement];
    return NO;
}

// by default Unity engine sets this to direct touch container, so we need to reset
- (UIAccessibilityTraits)accessibilityTraits
{
//    if ( [AppleAccessibilityRuntime.sharedInstance isAccessibilityEnabledForUnityView:self] )
//    {
//        return UIAccessibilityTraitNone;
//    }
//    return [super accessibilityTraits];
    return UIAccessibilityTraitNone;
}

- (NSArray *)accessibilityElements
{
    NSArray *nodeComponents = [UEOUnityEngineObject findObjectsOfType:@"Apple.Accessibility.UnityAccessibilityNode"];
    NSArray *nodes = [nodeComponents _ueoFlatMapedObjectsWithBlock:^id _Nonnull(id  _Nonnull obj) {
        if ( [obj isKindOfClass:UEOUnityAccessibilityNodeComponent.class] )
        {
            return [UnityAXElement nodeFrom:(UEOUnityAccessibilityNodeComponent *)obj];
        }
        return nil;
    }];
    return [nodes _unityAccessibilitySorted];
}

@end
