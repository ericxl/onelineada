#import "UnityEngineBridge.h"
#import "UnityEngineScene.h"
#import "UnityEngineComponent.h"

@implementation UnityEngineScene

+ (instancetype)current
{
    return [UnityEngineScene new];
}

@end

