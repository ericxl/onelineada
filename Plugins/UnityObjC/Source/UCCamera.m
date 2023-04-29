//
//  UCCamera.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCCamera.h"
#import "UCUtilities.h"

@implementation UCCamera

+ (UCCamera *)main
{
    return SAFE_CAST_CLASS(UCCamera, [UCCamera safeCSharpObjectForKey:@"main" forType:@"UnityEngine.Camera"]);
}

- (simd_float3)worldToScreenPoint:(simd_float3)screenPoint
{
    const char *vectorStr = UnityEngineCameraWorldToScreenPoint_CSharpFunc(self.instanceID, FROM_NSSTRING(UCSimdFloat3ToString(screenPoint)));
    return UCSimdFloat3FromString(TO_NSSTRING(vectorStr));
}

@end
