//
//  UEOUnityEngineCamera.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UEOUnityEngineCamera.h"
#import "UEOUtilities.h"

@implementation UEOUnityEngineCamera

+ (UEOUnityEngineCamera *)main
{
    return SAFE_CAST_CLASS(UEOUnityEngineCamera, [UEOUnityEngineCamera safeCSharpObjectForKey:@"main" forType:@"UnityEngine.Camera"]);
}

- (simd_float3)worldToScreenPoint:(simd_float3)screenPoint
{
    const char *vectorStr = UnityEngineCameraWorldToScreenPoint_CSharpFunc(self.instanceID, FROM_NSSTRING(UEOSimdFloat3ToString(screenPoint)));
    return UEOSimdFloat3FromString(TO_NSSTRING(vectorStr));
}

@end
