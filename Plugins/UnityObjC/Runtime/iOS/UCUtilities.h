//
//  UCUtilities.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UnityObjC.h"
#import <simd/simd.h>

#pragma pack(push)
#pragma pack(8)
typedef struct {
    float x;
    float y;
} NativeVector2;
typedef struct {
    float x;
    float y;
    float z;
} NativeVector3;
typedef struct {
    float x;
    float y;
    float z;
    float w;
} NativeVector4;
typedef struct {
    float x;
    float y;
    float width;
    float height;
} NativeRect;
typedef struct {
    float r;
    float g;
    float b;
    float a;
} NativeColor;
#pragma pack(pop)

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectTypeFullName, const char *, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectFindObjectsOfType, void, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectDestroy, void, (int));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVoidForKey, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKey, BOOL, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKey, float, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKey, double, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector2ForKey, NativeVector2, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKey, NativeVector3, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector4ForKey, NativeVector4, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpRectForKey, NativeRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpColorForKey, NativeColor, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKey, int, (int, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKeyStatic, BOOL, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKeyStatic, int, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKeyStatic, float, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKeyStatic, double, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector2ForKeyStatic, NativeVector2, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKeyStatic, NativeVector3, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector4ForKeyStatic, NativeVector4, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpRectForKeyStatic, NativeRect, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKeyStatic, int, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpBoolForKey, void, (int, const char *, BOOL));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpIntForKey, void, (int, const char *, int));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpFloatForKey, void, (int, const char *, float));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpDoubleForKey, void, (int, const char *, double));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpVector2ForKey, void, (int, const char *, NativeVector2));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpVector3ForKey, void, (int, const char *, NativeVector3));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpVector4ForKey, void, (int, const char *, NativeVector4));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpRectForKey, void, (int, const char *, NativeRect));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpColorForKey, void, (int, const char *, NativeColor));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpStringForKey, void, (int, const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpObjectForKey, void, (int, const char *, int));

CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponents, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInChildren, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInChildren, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInParent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInParent, void, (int, const char *));

#pragma mark GameObject

CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectGetComponent, int, (int, const char *));

#pragma mark Transform

CSHARP_BRIDGE_INTERFACE(UnityEngineTransformFind, int, (int, const char *));

#pragma mark RectTransform
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformGetWorldCorners, void, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformUtilityWorldToScreenPoint, NativeVector2, (int, NativeVector3));

#pragma mark Scene
CSHARP_BRIDGE_INTERFACE(UnityEngineSceneManagerGetActiveSceneIsLoaded, BOOL, (void));
CSHARP_BRIDGE_INTERFACE(UnityEngineSceneManagerGetActiveSceneName, const char *, (void));

#pragma mark Camera
CSHARP_BRIDGE_INTERFACE(UnityEngineCameraWorldToScreenPoint, NativeVector3, (int, NativeVector3));

extern BOOL _UEOCSharpFunctionsRegistrationCompleted(void);
extern id _UEOCSharpGetLatestData(void);

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UEOExtensions)
- (NSString *)ucDropFirst:(NSString *)substring;
- (NSString *)ucDropLast:(NSString *)substring;
@end

@interface NSArray<__covariant ObjectType> (UEOExtensions)
- (nullable ObjectType)ucSafeObjectAtIndex:(NSUInteger)index;
- (NSArray<ObjectType> *)ucFilterObjectsUsingBlock:(BOOL (NS_NOESCAPE ^)(ObjectType item))filterBlock;
- (nullable ObjectType)ucFirstObjectUsingBlock:(BOOL (NS_NOESCAPE ^)(ObjectType item))predicateBlock;
- (NSArray *)ucMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (NSArray *)ucFlatMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (ObjectType)ucMaxObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (ObjectType)ucMinObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (NSNumber *)ucMaxNumber;
- (NSNumber *)ucMinNumber;
+ (nullable instancetype)ucArrayByIgnoringNilElementsWithCount:(NSUInteger)elementCount, ...;
@end

@interface NSValue (UEOGExtensions)
+ (NSValue *)ucValueWithCGPoint:(CGPoint)point;
+ (NSValue *)ucValueWithCGSize:(CGSize)size;
+ (NSValue *)ucValueWithCGRect:(CGRect)rect;
+ (NSValue *)ucValueWithSIMDFloat2:(simd_float2)vector2;
+ (NSValue *)ucValueWithSIMDFloat3:(simd_float3)vector3;
+ (NSValue *)ucValueWithSIMDFloat4:(simd_float4)vector4;

- (CGPoint)ucCGPointValue;
- (CGSize)ucCGSizeValue;
- (CGRect)ucCGRectValue;
- (simd_float2)ucSIMDFloat2Value;
- (simd_float3)ucSIMDFloat3Value;
- (simd_float4)ucSIMDFloat4Value;
@end

extern CGPoint UCCGRectGetCenter(CGRect rect);

extern float UCSimdFloat3SquareMagnitude(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3Equal(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3ApproximatelyEqual(simd_float3 v1, simd_float3 v2);
extern BOOL UCSimdFloat3ApproximatelyEqualWithinMargin(simd_float3 v1, simd_float3 v2, float margin);

extern NSString *UCFormatFloatWithPercentage(float value);

#define __UCRectForRectsSentinel CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX)
#define UCRectForRects(firstRect, ...) _UCRectForRects(firstRect, ##__VA_ARGS__, __UCRectForRectsSentinel)
extern CGRect _UCRectForRects(CGRect firstArgument, ...);
extern CGRect UCUnionRects(NSArray<NSValue *> *rects);

NS_ASSUME_NONNULL_END
