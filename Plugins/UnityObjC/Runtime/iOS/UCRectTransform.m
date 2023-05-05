//
//  UCRectTransform.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCRectTransform.h"
#import "UCUtilities.h"

@implementation UCRectTransform

- (NSArray<NSString *> *)getWorldCorners
{
    return [TO_NSSTRING(UnityEngineRectTransformGetWorldCorners_CSharpFunc(self.instanceID)) ucToStringArray];
}

+ (simd_float2)rectUtilityWorldToScreenPoint:(nullable UCCamera *)camera worldPoint:(simd_float3)worldPoint
{
    return FROM_NATIVE_VECTOR2( UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc(camera.instanceID, TO_NATIVE_VECTOR3(worldPoint)));
}

@end
