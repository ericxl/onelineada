#import "UEOUnityEngineComponent.h"
#import "UEOBridge.h"

@implementation UnityEngineComponent

- (UnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UnityEngineComponent *> *)getComponents:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponents_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString _ueoToNumberArray] _ueoMapedObjects:^id(NSNumber *obj) {
        return [UnityEngineObject objectWithID:obj.intValue];
    }];
}

- (UnityEngineComponent *)getComponentInChildren:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UnityEngineComponent *> *)getComponentsInChildren:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString _ueoToNumberArray] _ueoMapedObjects:^id(NSNumber *obj) {
        return [UnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
