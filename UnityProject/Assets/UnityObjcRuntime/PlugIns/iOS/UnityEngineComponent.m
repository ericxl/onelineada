#import "UnityEngineBridge.h"
#import "UnityEngineComponent.h"


@interface UnityEngineComponent()
{
    int _instanceID;
}
@end


@implementation UnityEngineComponent

+ (instancetype)componentWithID:(int)instanceID
{
    UnityEngineComponent *result = [UnityEngineComponent new];
    result->_instanceID = instanceID;
    return result;
}

- (UnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = _GameAXDelegate_GetComponentForObject_Func(_instanceID, uebFromNSString(component));
    if (instanceID == -1)
    {
        return nil;
    }
    return [UnityEngineComponent componentWithID:instanceID];
}

- (UnityEngineComponent *)addComponent:(NSString *)component
{
    int instanceID = _GameAXDelegate_AddComponentForObject_Func(_instanceID, uebFromNSString(component));
    if (instanceID == -1)
    {
        return nil;
    }
    return [UnityEngineComponent componentWithID:instanceID];
}
@end

