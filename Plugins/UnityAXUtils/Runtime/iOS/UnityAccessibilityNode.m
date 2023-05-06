//
//  UnityAccessibilityNode.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import "UnityAXUtils.h"

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
        UnityAccessibilityNode *node = [cls new];
        node->_instanceID = component.instanceID;
        [_gNodeMap setObject:node forKey:@(component.instanceID)];
        object = node;
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

- (BOOL)isVisible
{
    return [self.gameObject activeInHierarchy];
}

- (CGRect)accessibilityFrame
{
    return CGRectZero;
}

@end

__attribute__((visibility("hidden")))
@interface _UnityAccessibilityNodeFrameCorrectionLoader: NSObject
@end
@implementation _UnityAccessibilityNodeFrameCorrectionLoader
+ (void)load { UnityAXSafeCategoryInstall(@"UnityAccessibilityNodeFrameAccessibility", @"UnityAccessibilityNode"); }
@end

UnityAXDefineSafeCategory(UnityAccessibilityNodeFrameAccessibility)

@implementation UnityAccessibilityNodeFrameAccessibility

- (CGRect)accessibilityFrame
{
    if ( [self respondsToSelector:@selector(unitySpaceAccessibilityFrame)] )
    {
        CGRect rect = [(UnityAccessibilityNode *)self unitySpaceAccessibilityFrame];
        CGFloat scale = [[UIScreen mainScreen] nativeScale];
        rect.origin.x /= scale;
        rect.origin.y /= scale;
        rect.size.width /= scale;
        rect.size.height /= scale;
        return rect;
    }
    return [super accessibilityFrame];
}

- (CGPoint)accessibilityActivationPoint
{
    if ( [self respondsToSelector:@selector(unitySpaceAccessibilityActivationPoint)] )
    {
        CGPoint point = [(UnityAccessibilityNode *)self unitySpaceAccessibilityActivationPoint];
        CGRect rect = CGRectMake(point.x, point.y, 0, 0);
        CGFloat scale = [[UIScreen mainScreen] nativeScale];
        rect.origin.x /= scale;
        rect.origin.y /= scale;
        rect.size.width /= scale;
        rect.size.height /= scale;
        return rect.origin;
    }
    return [super accessibilityActivationPoint];
}

@end
