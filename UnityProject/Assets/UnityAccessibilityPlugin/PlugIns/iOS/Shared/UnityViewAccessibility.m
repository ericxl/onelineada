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
#import "UnityAccessibilityNode.h"

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
    NSArray *nodeComponents = [UEOUnityEngineObject findObjectsOfType:@"UnityObjCRuntimeBehaviour"];
    NSArray *nodes = [nodeComponents _ueoFlatMapedObjectsWithBlock:^id _Nonnull(id  _Nonnull obj) {
        if ( [obj isKindOfClass:UEOUnityObjCRuntimeBehaviour.class] )
        {
            return [UnityAXElement nodeFrom:(UEOUnityObjCRuntimeBehaviour *)obj];
        }
        return nil;
    }];
    return [nodes _unityAccessibilitySorted];
}

@end
