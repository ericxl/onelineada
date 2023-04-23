//
//  UnityEngineGameObject.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UnityEngineGameObject.h"
#import "UnityEngineBridge.h"
#import "UnityEngineComponent.h"

@implementation UnityEngineGameObject

+ (instancetype)find:(NSString *)name
{
    int instanceID = _GameAXDelegate_GameObjectFind_Func(uebFromNSString(name));
    return [UnityEngineGameObject objectWithID:instanceID];
}

- (UnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = _GameAXDelegate_GetComponentForObject_Func(self.instanceID, uebFromNSString(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

- (UnityEngineComponent *)addComponent:(NSString *)component
{
    int instanceID = _GameAXDelegate_AddComponentForObject_Func(self.instanceID, uebFromNSString(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

@end
