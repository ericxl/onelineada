//
//  UCObject.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <simd/types.h>
#import <simd/vector_make.h>

NS_ASSUME_NONNULL_BEGIN

@interface UCObject: NSObject

+ (nullable instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)objectWithID:(int)instanceID;

@property (nonatomic, assign, readonly) int instanceID;
@property (nonatomic, strong, readonly) NSString *typeFullName;

@property (nonatomic, strong) NSString *name;

- (void)destroy;

- (void)safeCSharpPerformFunctionForKey:(NSString *)key;
- (BOOL)safeCSharpBoolForKey:(NSString *)key;
- (int)safeCSharpIntForKey:(NSString *)key;
- (float)safeCSharpFloatForKey:(NSString *)key;
- (double)safeCSharpDoubleForKey:(NSString *)key;
- (simd_float2)safeCSharpVector2ForKey:(NSString *)key;
- (simd_float3)safeCSharpVector3ForKey:(NSString *)key;
- (simd_float4)safeCSharpVector4ForKey:(NSString *)key;
- (CGRect)safeCSharpRectForKey:(NSString *)key;
- (simd_float4)safeCSharpColorForKey:(NSString *)key;
- (nullable NSString *)safeCSharpStringForKey:(NSString *)key;
- (nullable UCObject *)safeCSharpObjectForKey:(NSString *)key;

+ (BOOL)safeCSharpBoolForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (int)safeCSharpIntForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (float)safeCSharpFloatForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (double)safeCSharpDoubleForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (simd_float2)safeCSharpVector2ForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (simd_float4)safeCSharpVector4ForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (CGRect)safeCSharpRectForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable UCObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType;

- (void)safeSetCSharpBoolForKey:(NSString *)key value:(BOOL)value;
- (void)safeSetCSharpIntForKey:(NSString *)key value:(int)value;
- (void)safeSetCSharpFloatForKey:(NSString *)key value:(float)value;
- (void)safeSetCSharpDoubleForKey:(NSString *)key value:(double)value;
- (void)safeSetCSharpVector2ForKey:(NSString *)key value:(simd_float2)value;
- (void)safeSetCSharpVector3ForKey:(NSString *)key value:(simd_float3)value;
- (void)safeSetCSharpVector4ForKey:(NSString *)key value:(simd_float4)value;
- (void)safeSetCSharpRectForKey:(NSString *)key value:(CGRect)value;
- (void)safeSetCSharpColorForKey:(NSString *)key value:(simd_float4)value;
- (void)safeSetCSharpStringForKey:(NSString *)key value:(nullable NSString *)value;

+ (nullable NSArray<UCObject *> *)findObjectsOfType:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
