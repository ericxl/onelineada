//
//  UCUIOutline.m
//  UnityObjC
//
//  Created by Eric Liang on 5/5/23.
//

#import "UCUIOutline.h"
#import "UCUtilities.h"

@implementation UCUIOutline

- (simd_float2)effectDistance
{
    return [self safeCSharpVector2ForKey:@"effectDistance"];
}

- (void)setEffectDistance:(simd_float2)effectDistance
{
    return [self safeSetCSharpVector2ForKey:@"effectDistance" value:effectDistance];
}

- (simd_float4)effectColor
{
    return [self safeCSharpColorForKey:@"effectColor"];
}

- (void)setEffectColor:(simd_float4)effectColor
{
    return [self safeSetCSharpColorForKey:@"effectColor" value:effectColor];
}

@end
