//
//  UCGameObject.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCGameObject.h"
#import "UCUtilities.h"
#import "UCComponent.h"
#import "UCTransform.h"
#import "UCScene.h"

@implementation UCGameObject

- (int)layer
{
    return [self safeCSharpIntForKey:@"layer"];
}

- (NSString *)tag
{
    return [self safeCSharpStringForKey:@"tag"];
}

- (BOOL)activeSelf
{
    return [self safeCSharpBoolForKey:@"activeSelf"];
}

- (BOOL)activeInHierarchy
{
    return [self safeCSharpBoolForKey:@"activeInHierarchy"];
}

- (UCGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UCGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UCTransform *)transform
{
    return SAFE_CAST_CLASS(UCTransform, [self safeCSharpObjectForKey:@"transform"]);
}

+ (instancetype)find:(NSString *)name
{
    int instanceID = UnityEngineGameObjectFind_CSharpFunc(FROM_NSSTRING(name));
    return [UCGameObject objectWithID:instanceID];
}

- (UCComponent *)addComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectAddComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

- (UCComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UCComponent objectWithID:instanceID];
}

@end
