//
//  UCComponent.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCComponent.h"
#import "UCUtilities.h"
#import "UCGameObject.h"
#import "UCTransform.h"

@implementation UCComponent

- (NSString *)tag
{
    return [self safeCSharpStringForKey:@"tag"];
}

- (UCGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UCGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UCTransform *)transform
{
    return SAFE_CAST_CLASS(UCTransform, [self safeCSharpObjectForKey:@"transform"]);
}

- (UCComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (NSArray<UCComponent *> *)getComponents:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponents_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ucToNumberArray] ucMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UCObject objectWithID:obj.intValue];
    }];
}

- (UCComponent *)getComponentInChildren:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (NSArray<UCComponent *> *)getComponentsInChildren:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ucToNumberArray] ucMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UCObject objectWithID:obj.intValue];
    }];
}

- (UCComponent *)getComponentInParent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (NSArray<UCComponent *> *)getComponentsInParent:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineComponentGetComponentsInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component)));
    return [[arrayString ucToNumberArray] ucMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UCObject objectWithID:obj.intValue];
    }];
}

@end
