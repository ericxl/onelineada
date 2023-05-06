//
//  NSArray+UnityAccessibilityNode.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import "NSArray+UnityAccessibilityNode.h"
#import "UnityObjC.h"
#import "NSArray+UnityAXUtils.h"

@implementation NSArray (UnityAccessibilityAdditions)

- (NSArray *)_axModaledSorted
{
    id modalElement = [self ucFirstObjectUsingBlock:^BOOL(id  _Nonnull item) {
        return [item accessibilityViewIsModal] && [item isVisible];
    }];
    if ( modalElement != nil )
    {
        return @[modalElement];
    }
    else
    {
        return [[self ucFilterObjectsUsingBlock:^BOOL(id  _Nonnull item) {
            return [item isVisible];
        }] sortedArrayUsingSelector:NSSelectorFromString(@"accessibilityCompareGeometry:")];
    }
}

@end
