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

+ (instancetype)node:(UEOUnityEngineObject *)component withClass:(Class)axClass
{
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

- (UEOUnityEngineGameObject *)gameObject
{
    return [UEOUnityEngineGameObject objectWithID:self->_instanceID];
}

@end
