//
//  UnityAccessibilityNode.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UnityAccessibilityNode.h"

@implementation UnityAccessibilityNodeComponent

@end

@interface UnityAccessibilityNode()
{
    int _instanceID;
}
@end
@implementation UnityAccessibilityNode

static NSMutableDictionary<NSNumber *, UnityAccessibilityNode *> *_gNodeMap;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gNodeMap = [NSMutableDictionary new];
    });
}

+ (instancetype)nodeFrom:(UnityAccessibilityNodeComponent *)component
{
    if ( component == nil )
    {
        return nil;
    }
    if ( ![component.typeFullName isEqualToString:@"Apple.Accessibility.UnityAccessibilityNode"] )
    {
        return nil;
    }
    if ( [_gNodeMap objectForKey:@(component.instanceID)] != nil )
    {
        return [_gNodeMap objectForKey:@(component.instanceID)];
    }
    UnityAccessibilityNode *node = [UnityAccessibilityNode new];
    node->_instanceID = component.instanceID;
    [_gNodeMap setObject:node forKey:@(component.instanceID)];
    return node;
}

- (UnityAccessibilityNodeComponent *)component
{
    return [UnityAccessibilityNodeComponent objectWithID:self->_instanceID];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return [self.component description];
}

- (CGRect)accessibilityFrame
{
    return CGRectMake(0, 0, 100, 100);
}

@end
