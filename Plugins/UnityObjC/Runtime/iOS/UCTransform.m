//
//  UCTransform.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCTransform.h"
#import "UCUtilities.h"

@implementation UCTransform

- (nullable UCTransform *)find:(NSString *)childName
{
    int instanceID = UnityEngineTransformFind_CSharpFunc(self.instanceID, FROM_NSSTRING(childName));
    return SAFE_CAST_CLASS(UCTransform, [UCTransform objectWithID:instanceID]);
}

- (int)siblingIndex
{
    return [self safeCSharpIntForKey:@"GetSiblingIndex"];
}

- (void)setSiblingIndex:(int)siblingIndex
{
    [self safeSetCSharpIntForKey:@"SetSiblingIndex" value:siblingIndex];
}

- (UCTransform *)parent
{
    return SAFE_CAST_CLASS(UCTransform, [self safeCSharpObjectForKey:@"parent"]);
}

- (void)setParent:(UCTransform *)parent
{
    [self safeSetCSharpObjectForKey:@"parent" value:parent];
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
