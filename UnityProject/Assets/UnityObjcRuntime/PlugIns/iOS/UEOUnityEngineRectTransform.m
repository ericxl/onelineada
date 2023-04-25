//
//  UEOUnityEngineRectTransform.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UEOUnityEngineRectTransform.h"
#import "UEOBase.h"
#import "UEOBridge.h"
#import "UEOUtilities.h"
@implementation UEOUnityEngineRectTransform

- (NSArray<NSString *> *)getWorldCorners
{
    return [TO_NSSTRING(UnityEngineRectTransformGetWorldCorners_CSharpFunc(self.instanceID)) _ueoToStringArray];
}

+ (simd_float2)rectUtilityWorldToScreenPoint:(nullable UEOUnityEngineCamera *)camera worldPoint:(simd_float3)worldPoint
{
    return UEOSimdFloat2FromString(TO_NSSTRING(UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc(camera.instanceID, FROM_NSSTRING(UEOSimdFloat3ToString(worldPoint)))));
}

@end
