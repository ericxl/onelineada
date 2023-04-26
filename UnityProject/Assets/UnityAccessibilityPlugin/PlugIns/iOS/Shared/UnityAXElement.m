//
//  UnityAccessibilityNode.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UnityAXElement.h"

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

+ (instancetype)nodeFrom:(UEOUnityObjCRuntimeBehaviour *)component
{
    if ( component == nil )
    {
        return nil;
    }
    if ( ![component.typeFullName isEqualToString:@"UnityObjCRuntimeBehaviour"] )
    {
        return nil;
    }
    id object = [_gNodeMap objectForKey:@(component.instanceID)];
    Class cls = UnityAXElement.class;
    NSString *className = [component className];
    if ( className.length != 0 && NSClassFromString(className) != Nil)
    {
        cls = NSClassFromString(className);
    }
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

- (UEOUnityObjCRuntimeBehaviour *)component
{
    return [UEOUnityObjCRuntimeBehaviour objectWithID:self->_instanceID];
}

- (UEOUnityEngineGameObject *)gameObject
{
    return [self.component gameObject];
}

@end


@implementation UEOUnityObjCRuntimeBehaviour(AccessibilityExtension)

- (NSString *)className
{
    return [self safeCSharpStringForKey:@"AccessibilityElementClassName"];;
}

- (void)setClassName:(NSString *)className
{
    [self safeSetCSharpStringForKey:@"AccessibilityElementClassName" value:className];
}

@end
