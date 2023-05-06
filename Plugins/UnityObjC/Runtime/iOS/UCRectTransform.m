//
//  UCRectTransform.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCRectTransform.h"
#import "UCUtilities.h"

@implementation UCRectTransform

static simd_float3 _SimdFloat3FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 3 )
    {
        return simd_make_float3(0, 0, 0);
    }
    return simd_make_float3([components[0] floatValue], [components[1] floatValue], [components[2] floatValue]);
}

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
