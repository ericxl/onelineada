//
//  UnityEngineGameObject.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUnityEngineGameObject.h"
#import "UEOUtilities.h"
#import "UEOUnityEngineComponent.h"
#import "UEOUnityEngineTransform.h"
#import "UEOUnityEngineScene.h"

@implementation UEOUnityEngineGameObject

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

- (UEOUnityEngineGameObject *)gameObject
{
    return SAFE_CAST_CLASS(UEOUnityEngineGameObject, [self safeCSharpObjectForKey:@"gameObject"]);
}

- (UEOUnityEngineTransform *)transform
{
    return SAFE_CAST_CLASS(UEOUnityEngineTransform, [self safeCSharpObjectForKey:@"transform"]);
}

- (UEOUnityEngineScene *)scene
{
    return SAFE_CAST_CLASS(UEOUnityEngineScene, [self safeCSharpObjectForKey:@"scene"]);
}

+ (instancetype)find:(NSString *)name
{
    int instanceID = UnityEngineGameObjectFind_CSharpFunc(FROM_NSSTRING(name));
    return [UEOUnityEngineGameObject objectWithID:instanceID];
}

- (UEOUnityEngineComponent *)addComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectAddComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UEOUnityEngineComponent objectWithID:instanceID];
}

- (UEOUnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineGameObjectGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UEOUnityEngineComponent objectWithID:instanceID];
}

@end
