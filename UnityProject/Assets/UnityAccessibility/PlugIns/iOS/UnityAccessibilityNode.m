//
//  UnityAccessibilityNode.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UnityAccessibilityNode.h"

@implementation UEOUnityAccessibilityNodeComponent

- (NSString *)className
{
    return [self safeCSharpStringForKey:@"ClassName"];
}

- (void)setClassName:(NSString *)className
{
    [self safeSetCSharpStringForKey:@"ClassName" value:className];
}

@end

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

+ (instancetype)nodeFrom:(UEOUnityAccessibilityNodeComponent *)component
{
    if ( component == nil )
    {
        return nil;
    }
    if ( ![component.typeFullName isEqualToString:@"Apple.Accessibility.UnityAccessibilityNode"] )
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

- (UEOUnityAccessibilityNodeComponent *)component
{
    return [UEOUnityAccessibilityNodeComponent objectWithID:self->_instanceID];
}

- (UEOUnityEngineGameObject *)gameObject
{
    return [self.component gameObject];
}

@end
