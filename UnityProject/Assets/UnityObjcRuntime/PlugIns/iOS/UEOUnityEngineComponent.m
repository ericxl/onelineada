#import "UEOUnityEngineComponent.h"
#import "UEOBridge.h"
#import "UEOUnityEngineGameObject.h"
#import "UEOUnityEngineTransform.h"

@implementation UnityEngineComponent

- (NSString *)tag
{
    return [self safeCSharpStringForKey:@"tag"];
}

- (UnityEngineGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UnityEngineGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UnityEngineTransform *)transform
{
    return SAFE_CAST_CLASS(UnityEngineTransform, [self safeCSharpObjectForKey:@"transform"]);
}

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

- (UnityEngineComponent *)getComponentInParent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UnityEngineComponent *> *)getComponentsInParent:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString _ueoToNumberArray] _ueoMapedObjects:^id(NSNumber *obj) {
        return [UnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
