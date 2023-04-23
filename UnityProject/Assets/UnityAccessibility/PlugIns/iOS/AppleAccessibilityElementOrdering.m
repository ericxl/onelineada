//
//  AppleAccessibilityElementOrdering.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import "AppleAccessibilityElementOrdering.h"
#import <UIKit/UIKit.h>

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
