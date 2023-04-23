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
