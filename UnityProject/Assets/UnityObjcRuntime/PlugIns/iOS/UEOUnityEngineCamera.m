//
//  UEOUnityEngineCamera.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UEOUnityEngineCamera.h"
#import "UEOBridge.h"
#import "UEOUtilities.h"

@implementation UEOUnityEngineCamera

+ (UEOUnityEngineCamera *)main
{
    return SAFE_CAST_CLASS(UEOUnityEngineCamera, [UEOUnityEngineCamera safeCSharpObjectForKey:@"main" forType:@"UnityEngine.Camera"]);
}

@end
