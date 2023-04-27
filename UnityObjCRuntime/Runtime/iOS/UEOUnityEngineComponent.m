#import "UEOUnityEngineComponent.h"
#import "UEOUtilities.h"
#import "UEOUnityEngineGameObject.h"
#import "UEOUnityEngineTransform.h"

@implementation UEOUnityEngineComponent

- (NSString *)tag
{
    return [self safeCSharpStringForKey:@"tag"];
}

- (UEOUnityEngineGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UEOUnityEngineGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UEOUnityEngineTransform *)transform
{
    return SAFE_CAST_CLASS(UEOUnityEngineTransform, [self safeCSharpObjectForKey:@"transform"]);
}

- (UEOUnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UEOUnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UEOUnityEngineComponent *> *)getComponents:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponents_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ueoToNumberArray] ueoMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UEOUnityEngineObject objectWithID:obj.intValue];
    }];
}

- (UEOUnityEngineComponent *)getComponentInChildren:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UEOUnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UEOUnityEngineComponent *> *)getComponentsInChildren:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ueoToNumberArray] ueoMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UEOUnityEngineObject objectWithID:obj.intValue];
    }];
}

- (UEOUnityEngineComponent *)getComponentInParent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UEOUnityEngineComponent objectWithID:instanceID];
}

- (NSArray<UEOUnityEngineComponent *> *)getComponentsInParent:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ueoToNumberArray] ueoMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UEOUnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
