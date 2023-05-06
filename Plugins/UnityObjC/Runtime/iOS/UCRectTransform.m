//
//  UCRectTransform.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCRectTransform.h"
#import "UCUtilities.h"

@implementation UCRectTransform

- (NSArray<NSValue *> *)getWorldCorners
{
    UnityEngineRectTransformGetWorldCorners_CSharpFunc(self.instanceID);
    return _UEOCSharpGetLatestData();
}

+ (simd_float2)rectUtilityWorldToScreenPoint:(nullable UCCamera *)camera worldPoint:(simd_float3)worldPoint
{
    return FROM_NATIVE_VECTOR2( UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc(camera.instanceID, TO_NATIVE_VECTOR3(worldPoint)));
}

@end
