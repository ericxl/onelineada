#import "UEOUnityEngineComponent.h"
#import "UEOBridge.h"

@implementation UnityEngineComponent

- (UnityEngineComponent *)getComponent:(NSString *)component
{
    int instanceID = UnityEngineComponentGetComponent_CSharpFunc(self.instanceID, FROM_NSSTRING(component));
    return [UnityEngineComponent objectWithID:instanceID];
}

@end
