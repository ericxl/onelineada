//
//  UnityAccessibility.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UnityAccessibility.h"

@interface UnityAXElement()
{
    int _instanceID;
}
@end
@implementation UnityAXElement

static NSMutableDictionary<NSNumber *, UnityAXElement *> *_gNodeMap;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gNodeMap = [NSMutableDictionary new];
    });
}

+ (instancetype)node:(UCObject *)component withClass:(Class)axClass
{
    if ( ![component isKindOfClass:UCGameObject.class] )
    {
        if ( [component isKindOfClass:UCComponent.class] )
        {
            component = [(UCComponent *)component gameObject];
        }
    }
    if ( component == nil )
    {
        return nil;
    }
    
    id object = [_gNodeMap objectForKey:@(component.instanceID)];
    Class cls = axClass;
    if ( object != nil )
    {
        if ( [object class] != cls )
        {
            object = nil;
        }
    }
    if ( object == nil )
    {
        UnityAXElement *node = [cls new];
        node->_instanceID = component.instanceID;
        [_gNodeMap setObject:node forKey:@(component.instanceID)];
    }
    return object;
}

- (UCTransform *)transform
{
    return [self.gameObject transform];
}

- (UCGameObject *)gameObject
{
    return [UCGameObject objectWithID:self->_instanceID];
}

@end

@implementation NSArray (UnityAccessibilityAdditions)

- (NSArray *)_axModaledSorted
{
    id modalElement = [self ucFirstObjectUsingBlock:^BOOL(id  _Nonnull item) {
        return [item accessibilityViewIsModal] && ![item accessibilityElementsHidden];
    }];
    if ( modalElement != nil )
    {
        return @[modalElement];
    }
    else
    {
        return [[self ucFilterObjectsUsingBlock:^BOOL(id  _Nonnull item) {
            return ![item accessibilityElementsHidden];
        }] sortedArrayUsingSelector:NSSelectorFromString(@"accessibilityCompareGeometry:")];
    }
}

@end

@interface _AXGameGlue: NSObject
@end
@implementation _AXGameGlue
+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _ObjCSafeOverrideInstall(@"UnityViewAccessibility");
    });
}
@end
