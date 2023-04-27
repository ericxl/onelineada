#import "UEOUtilities.h"
#import "UEOUnityEngineScene.h"
#import "UEOUnityEngineComponent.h"

@implementation UEOUnityEngineScene

+ (BOOL)activeSceneIsLoaded
{
    return UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc();
}

+ (nullable NSString *)activeSceneName
{
    return TO_NSSTRING(UnityEngineSceneManagerGetActiveSceneName_CSharpFunc());
}

@end

