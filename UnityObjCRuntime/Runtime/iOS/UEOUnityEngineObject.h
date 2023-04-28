#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <simd/types.h>
#import <simd/vector_make.h>

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineObject: NSObject

+ (nullable instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)objectWithID:(int)instanceID;

@property (nonatomic, assign, readonly) int instanceID;
@property (nonatomic, strong, readonly) NSString *typeFullName;

@property (nonatomic, strong) NSString *name;

- (void)safeCSharpPerformFunctionForKey:(NSString *)key;
- (BOOL)safeCSharpBoolForKey:(NSString *)key;
- (int)safeCSharpIntForKey:(NSString *)key;
- (float)safeCSharpFloatForKey:(NSString *)key;
- (double)safeCSharpDoubleForKey:(NSString *)key;
- (simd_float2)safeCSharpVector2ForKey:(NSString *)key;
- (simd_float3)safeCSharpVector3ForKey:(NSString *)key;
- (simd_float4)safeCSharpVector4ForKey:(NSString *)key;
- (CGRect)safeCSharpRectForKey:(NSString *)key;
- (nullable NSString *)safeCSharpStringForKey:(NSString *)key;
- (nullable UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key;
+ (BOOL)safeCSharpBoolForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (int)safeCSharpIntForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType;

- (void)safeSetCSharpBoolForKey:(NSString *)key value:(BOOL)value;
- (void)safeSetCSharpIntForKey:(NSString *)key value:(int)value;
- (void)safeSetCSharpFloatForKey:(NSString *)key value:(float)value;
- (void)safeSetCSharpDoubleForKey:(NSString *)key value:(double)value;
- (void)safeSetCSharpVector2ForKey:(NSString *)key value:(simd_float2)value;
- (void)safeSetCSharpVector3ForKey:(NSString *)key value:(simd_float3)value;
- (void)safeSetCSharpVector4ForKey:(NSString *)key value:(simd_float4)value;
- (void)safeSetCSharpStringForKey:(NSString *)key value:(nullable NSString *)value;

+ (nullable NSArray<UEOUnityEngineObject *> *)findObjectsOfType:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
