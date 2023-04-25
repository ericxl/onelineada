//
//  UEOUtilities.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"
#import <simd/types.h>
#import <simd/vector_make.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UEOExtensions)
- (nullable NSArray<NSNumber *> *)_ueoToNumberArray;
- (nullable NSArray<NSString *> *)_ueoToStringArray;
@end

@interface NSArray<ObjectType> (UEOExtensions)
- (NSArray *)_ueoMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (NSArray *)_ueoFlatMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (ObjectType)_ueoMaxObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (ObjectType)_ueoMinObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
@end

extern NSString *UEOSimdFloat2ToString(simd_float2 vector);
extern simd_float2 UEOSimdFloat2FromString(NSString *str);
extern NSArray<NSNumber *> *UEOSimdFloat2ToArray(simd_float2 vector);
extern simd_float2 UEOSimdFloat2FromArray(NSArray<NSNumber *> *array);

extern NSString *UEOSimdFloat3ToString(simd_float3 vector);
extern simd_float3 UEOSimdFloat3FromString(NSString *str);
extern NSArray<NSNumber *> *UEOSimdFloat3ToArray(simd_float3 vector);
extern simd_float3 UEOSimdFloat3FromArray(NSArray<NSNumber *> *array);

NS_ASSUME_NONNULL_END
