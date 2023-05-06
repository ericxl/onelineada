//
//  Simd+UnityAXUtils.m
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import "Simd+UnityAXUtils.h"

float UCSimdFloat3SquareMagnitude(simd_float3 v1, simd_float3 v2)
{
    simd_float3 diff = v1 - v2;
    return simd_dot(diff, diff);
}

BOOL UCSimdFloat3Equal(simd_float3 v1, simd_float3 v2)
{
    return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

static const float EPSILON = 1e-6;
BOOL UCSimdFloat3ApproximatelyEqual(simd_float3 v1, simd_float3 v2)
{
    return UCSimdFloat3SquareMagnitude(v1, v2) < EPSILON;
}

BOOL UCSimdFloat3ApproximatelyEqualWithinMargin(simd_float3 v1, simd_float3 v2, float margin)
{
    return UCSimdFloat3SquareMagnitude(v1, v2) < margin;
}

