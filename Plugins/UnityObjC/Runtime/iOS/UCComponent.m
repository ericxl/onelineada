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
    UnityEngineComponentGetComponents_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    NSArray *instanceIDs = _UEOCSharpGetLatestData();
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[instanceIDs count]];
    [instanceIDs enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[UCObject objectWithID:obj.intValue]];
    }];
    return result;
}

- (UCComponent *)getComponentInChildren:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (NSArray<UCComponent *> *)getComponentsInChildren:(NSString *)component
{
    UnityEngineComponentGetComponentsInChildren_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    NSArray *instanceIDs = _UEOCSharpGetLatestData();
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[instanceIDs count]];
    [instanceIDs enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[UCObject objectWithID:obj.intValue]];
    }];
    return result;
}

- (UCComponent *)getComponentInParent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponentInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (NSArray<UCComponent *> *)getComponentsInParent:(NSString *)component
{
    UnityEngineComponentGetComponentsInParent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    NSArray *instanceIDs = _UEOCSharpGetLatestData();
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[instanceIDs count]];
    [instanceIDs enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[UCObject objectWithID:obj.intValue]];
    }];
    return result;
}

@end
