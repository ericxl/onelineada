//
//  Simd+UnityAXUtils.h
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

extern float UCSimdFloat3SquareMagnitude(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3Equal(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3ApproximatelyEqual(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3ApproximatelyEqualWithinMargin(simd_float3 v1, simd_float3 v2, float margin);

NS_ASSUME_NONNULL_END
