//
//  UCScene.m
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCUtilities.h"
#import "UCScene.h"
#import "UCComponent.h"

@implementation UCScene

+ (BOOL)activeSceneIsLoaded
{
    return UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc();
}

+ (nullable NSString *)activeSceneName
{
    return TO_NSSTRING(UnityEngineSceneManagerGetActiveSceneName_CSharpFunc());
}

@end

