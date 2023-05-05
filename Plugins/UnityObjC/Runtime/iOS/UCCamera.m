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
    return FROM_NATIVE_VECTOR3(UnityEngineCameraWorldToScreenPoint_CSharpFunc(self.instanceID, TO_NATIVE_VECTOR3(screenPoint)));
}

@end
