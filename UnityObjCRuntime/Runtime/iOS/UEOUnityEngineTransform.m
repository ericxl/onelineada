//
//  UEOUnityEngineTransform.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUnityEngineTransform.h"
#import "UEOUtilities.h"

@implementation UEOUnityEngineTransform

- (nullable UEOUnityEngineTransform *)find:(NSString *)childName
{
    int instanceID = UnityEngineTransformFind_CSharpFunc(self.instanceID, FROM_NSSTRING(childName));
    return SAFE_CAST_CLASS(UEOUnityEngineTransform, [UEOUnityEngineTransform objectWithID:instanceID]);
}

- (simd_float3)position
{
    return [self safeCSharpVector3ForKey:@"position"];
}

- (void)setPosition:(simd_float3)position
{
    [self safeSetCSharpVector3ForKey:@"position" value:position];
}

- (simd_float3)localScale
{
    return [self safeCSharpVector3ForKey:@"localScale"];
}

- (void)setLocalScale:(simd_float3)localScale
{
    [self safeSetCSharpVector3ForKey:@"localScale" value:localScale];
}

@end
