//
//  UCUtilities.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUtilities.h"

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectTypeFullName);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectFindObjectsOfType);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectDestroy);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVoidForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector2ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector4ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpRectForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpColorForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector2ForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector4ForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpRectForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKeyStatic);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpBoolForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpIntForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpFloatForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpDoubleForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector2ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector3ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector4ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpRectForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpColorForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpStringForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpObjectForKey);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponents);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentInChildren);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentsInChildren);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentInParent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentsInParent);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectFind);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectAddComponent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectGetComponent);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineTransformFind);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineRectTransformGetWorldCorners);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineRectTransformUtilityWorldToScreenPoint);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineSceneManagerGetActiveSceneIsLoaded);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineSceneManagerGetActiveSceneName);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineCameraWorldToScreenPoint);

static id _gDataBridge = nil;
extern void _UEODataBridgeClear(void)
{
    _gDataBridge = nil;
}

id _UEOCSharpGetLatestData(void)
{
    return _gDataBridge;
}

extern void _UEODataBridgePopulateIntArray(const int* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        [_gDataBridge addObject:@(array[i])];
    }
}

extern void _UEODataBridgePopulateVector2Array(const NativeVector2* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        [_gDataBridge addObject:[NSValue ucValueWithSIMDFloat2:FROM_NATIVE_VECTOR2(array[i])]];
    }
}

extern void _UEODataBridgePopulateVector3Array(const NativeVector3* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        [_gDataBridge addObject:[NSValue ucValueWithSIMDFloat3:FROM_NATIVE_VECTOR3(array[i])]];
    }
}

extern void _UEODataBridgePopulateVector4Array(const NativeVector4* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        [_gDataBridge addObject:[NSValue ucValueWithSIMDFloat4:FROM_NATIVE_VECTOR4(array[i])]];
    }
}


BOOL _UEOCSharpFunctionsRegistrationCompleted(void)
{
    return YES
    && UnityEngineObjectTypeFullName_CSharpFunc != NULL
    && UnityEngineObjectFindObjectsOfType_CSharpFunc != NULL
    && UnityEngineObjectDestroy_CSharpFunc != NULL
    
    && UnityEngineObjectSafeCSharpVoidForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpIntForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpFloatForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpDoubleForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpRectForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpColorForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpStringForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpObjectForKey_CSharpFunc != NULL
    
    && UnityEngineObjectSafeCSharpBoolForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpFloatForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpDoubleForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector2ForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector3ForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector4ForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpRectForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpStringForKeyStatic_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc != NULL

    && UnityEngineObjectSafeSetCSharpBoolForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpIntForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpFloatForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpDoubleForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpVector2ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpVector3ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpVector4ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpRectForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpColorForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeSetCSharpObjectForKey_CSharpFunc != NULL

    && UnityEngineComponentGetComponent_CSharpFunc != NULL
    && UnityEngineComponentGetComponents_CSharpFunc != NULL
    && UnityEngineComponentGetComponentInChildren_CSharpFunc != NULL
    && UnityEngineComponentGetComponentsInChildren_CSharpFunc != NULL
    && UnityEngineComponentGetComponentInParent_CSharpFunc != NULL
    && UnityEngineComponentGetComponentsInParent_CSharpFunc != NULL

    && UnityEngineGameObjectFind_CSharpFunc != NULL
    && UnityEngineGameObjectAddComponent_CSharpFunc != NULL
    && UnityEngineGameObjectGetComponent_CSharpFunc != NULL

    && UnityEngineTransformFind_CSharpFunc != NULL

    && UnityEngineRectTransformGetWorldCorners_CSharpFunc != NULL
    && UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc != NULL

    && UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc != NULL
    && UnityEngineSceneManagerGetActiveSceneName_CSharpFunc != NULL

    && UnityEngineCameraWorldToScreenPoint_CSharpFunc != NULL
    ;
}

@implementation NSValue (UEOGExtensions)
+ (NSValue *)ucValueWithCGPoint:(CGPoint)point
{
    return [NSValue valueWithBytes:&point objCType:@encode(CGPoint)];
}

+ (NSValue *)ucValueWithCGSize:(CGSize)size
{
    return [NSValue valueWithBytes:&size objCType:@encode(CGSize)];
}

+ (NSValue *)ucValueWithCGRect:(CGRect)rect
{
    return [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
}

+ (NSValue *)ucValueWithSIMDFloat2:(simd_float2)vector2
{
    return [NSValue valueWithBytes:&vector2 objCType:@encode(float[4])];
}

+ (NSValue *)ucValueWithSIMDFloat3:(simd_float3)vector3
{
    return [NSValue valueWithBytes:&vector3 objCType:@encode(float[4])];
}

+ (NSValue *)ucValueWithSIMDFloat4:(simd_float4)vector4
{
    return [NSValue valueWithBytes:&vector4 objCType:@encode(float[4])];
}

- (CGPoint)ucCGPointValue
{
    CGPoint result;
    [self getValue:&result size:sizeof(CGPoint)];
    return result;
}


- (CGSize)ucCGSizeValue
{
    CGSize result;
    [self getValue:&result size:sizeof(CGSize)];
    return result;
}

- (CGRect)ucCGRectValue
{
    CGRect result;
    [self getValue:&result size:sizeof(CGRect)];
    return result;
}

- (simd_float2)ucSIMDFloat2Value
{
    simd_float2 result;
    [self getValue:&result size:sizeof(simd_float4)]; // not a mistake!
    return result;
}

- (simd_float3)ucSIMDFloat3Value
{
    simd_float3 result;
    [self getValue:&result size:sizeof(simd_float4)]; // not a mistake!
    return result;
}

- (simd_float4)ucSIMDFloat4Value
{
    simd_float4 result;
    [self getValue:&result size:sizeof(simd_float4)];
    return result;
}

@end
