//
//  UnityEngineGameObject.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUnityEngineGameObject.h"
#import "UEOBridge.h"
#import "UEOUnityEngineComponent.h"
#import "UEOUnityEngineTransform.h"
#import "UEOUnityEngineScene.h"

@implementation UnityEngineGameObject

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

- (UnityEngineGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UnityEngineGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UnityEngineTransform *)transform
{
    return SAFE_CAST_CLASS(UnityEngineTransform, [self safeCSharpObjectForKey:@"transform"]);
}

- (UnityEngineScene *)scene
{
    return SAFE_CAST_CLASS(UnityEngineScene, [self safeCSharpObjectForKey:@"scene"]);
}

+ (instancetype)find:(NSString *)name
{
    int instanceID = UnityEngineGameObjectFind_CSharpFunc(FROM_NSSTRING(name));
    return [UnityEngineGameObject objectWithID:instanceID];
}

- (UnityEngineComponent *)addComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectAddComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

- (UnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

@end
