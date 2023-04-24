//
//  UnityViewAccessibility.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AppleAccessibilityRuntime.h"
#import "AppleAccessibilitySafeOverride.h"
#import "AppleAccessibilityElementOrdering.h"

#import "UnityEngineObjC.h"
#import "UnityAccessibilityNode.h"

AppleAccessibilityDefineSafeOverride(@"UnityView", UnityViewAccessibility)

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
//    return [AppleAccessibilityRuntime.sharedInstance accessibilityChildrenForUnityView:self];
    NSArray *nodeComponents = [UnityEngineObject findObjectsOfType:@"Apple.Accessibility.UnityAccessibilityNode"];
    NSArray *nodes = [nodeComponents _ueoFlatMapedObjects:^id _Nonnull(id  _Nonnull obj) {
        if ( [obj isKindOfClass:UnityAccessibilityNodeComponent.class] )
        {
            return [UnityAccessibilityNode nodeFrom:(UnityAccessibilityNodeComponent *)obj];
        }
        return nil;
    }];
    return [nodes _unityAccessibilitySorted];
}

@end
