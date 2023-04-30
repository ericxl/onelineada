//
//  UCUtilities.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectTypeFullName);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectFindObjectsOfType);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVoidForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector2ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector4ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpRectForKey);
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

BOOL _UEOCSharpFunctionsRegistrationCompleted(void)
{
    return YES
    && UnityEngineObjectTypeFullName_CSharpFunc != NULL
    && UnityEngineObjectTypeFullName_CSharpFunc != NULL
    && UnityEngineObjectFindObjectsOfType_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVoidForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpIntForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpFloatForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpDoubleForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc != NULL
    && UnityEngineObjectSafeCSharpRectForKey_CSharpFunc != NULL
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

@implementation NSString (UEOExtensions)

- (NSArray<NSNumber *> *)ucToNumberArray
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];

    // Use NSJSONSerialization to parse the JSON data
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (jsonArray && !error) {
        // Create a mutable array to store the NSNumber objects
        NSMutableArray<NSNumber *> *numberArray = [NSMutableArray arrayWithCapacity:[jsonArray count]];

        // Iterate through the parsed array and convert each element to NSNumber
        for (id element in jsonArray) {
            if ([element isKindOfClass:[NSNumber class]]) {
                [numberArray addObject:(NSNumber *)element];
            }
        }

        // Convert the mutable array to an NSArray
        return [NSArray arrayWithArray:numberArray];
    }
    return nil;
}

- (NSArray<NSString *> *)ucToStringArray
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\((.*?)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];

    NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:[matches count]];
    for (NSTextCheckingResult *match in matches)
    {
        NSString *substring = [self substringWithRange:[match rangeAtIndex:0]];
        [substrings addObject:substring];
    }
    return [substrings copy];
}

- (NSString *)ucDropFirst:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring];
    if ( range.location != NSNotFound && range.location == 0 )
    {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    else
    {
        return self;
    }
}

- (NSString *)ucDropLast:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring options:NSBackwardsSearch];
    if ( range.location != NSNotFound && range.location + range.length == self.length )
    {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    else
    {
        return self;
    }
}

@end

@implementation NSArray (UEOExtensions)

- (id)ucSafeObjectAtIndex:(NSUInteger)index
{
    if ( index < [self count] )
    {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (NSArray *)ucFilterObjectsUsingBlock:(BOOL (NS_NOESCAPE ^)(id item))filterBlock
{
    if ( filterBlock == nil )
    {
        return [self copy];
    }

    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id __nonnull obj, NSUInteger idx, BOOL *__nonnull stop) {
        if ( filterBlock(obj) )
        {
            [result addObject:obj];
        }
    }];

    return result;
}

- (id)ucFirstObjectUsingBlock:(BOOL (NS_NOESCAPE ^)(id item))predicateBlock
{
    if ( predicateBlock == nil )
    {
        return [self firstObject];
    }
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id __nonnull obj, NSUInteger idx, BOOL *__nonnull stop) {
        if ( predicateBlock(obj) )
        {
            result = obj;
            *stop = YES;
        }
    }];

    return result;
}

- (NSArray *)ucMapedObjectsWithBlock:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray new];
    for ( id object in self )
    {
        id mapped = block(object);
        [result addObject:mapped];
    }
    return [result copy];
}

- (NSArray *)ucFlatMapedObjectsWithBlock:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self)
    {
        id mapped = block(object);
        if ( mapped != nil )
        {
            [result addObject:mapped];
        }
    }
    return [result copy];
}

- (id)ucMaxObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id maxObject = nil;

    for (id object in self) {
        if (maxObject == nil || block(object, maxObject) == NSOrderedDescending) {
            maxObject = object;
        }
    }

    return maxObject;
}

- (id)ucMinObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id minObject = nil;

    for (id object in self) {
        if (minObject == nil || block(object, minObject) == NSOrderedAscending) {
            minObject = object;
        }
    }

    return minObject;
}

- (NSNumber *)ucMaxNumber
{
    return [self ucMaxObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
}
- (NSNumber *)ucMinNumber
{
    return [self ucMinObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
}

+ (instancetype)ucArrayByIgnoringNilElementsWithCount:(NSUInteger)elementCount, ...
{
    NSMutableArray *result = [NSMutableArray array];

    va_list args;
    va_start(args, elementCount);
    for ( NSUInteger i = 0; i < elementCount; i++ )
    {
        id value = va_arg(args, id);
        if ( value != nil )
        {
            [result addObject:value];
        }
    }
    va_end(args);
    return result;
}

@end

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
    [self getValue:&result size:sizeof(simd_float2)];
    return result;
}

- (simd_float3)ucSIMDFloat3Value
{
    simd_float3 result;
    [self getValue:&result size:sizeof(simd_float3)];
    return result;
}

- (simd_float4)ucSIMDFloat4Value
{
    simd_float4 result;
    [self getValue:&result size:sizeof(simd_float4)];
    return result;
}

@end

CGPoint UCCGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

NSString *UCSimdFloat2ToString(simd_float2 vector)
{
    return [NSString stringWithFormat:@"(%f, %f)", vector[0], vector[1]];
}

NSString *UCSimdFloat3ToString(simd_float3 vector)
{
    return [NSString stringWithFormat:@"(%f, %f, %f)", vector.x, vector.y, vector.z];
}

NSString *UCSimdFloat4ToString(simd_float4 vector)
{
    return [NSString stringWithFormat:@"(%f, %f, %f, %f)", vector.x, vector.y, vector.z, vector.w];
}

simd_float2 UCSimdFloat2FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 2)
    {
        return simd_make_float2(0, 0);
    }
    return simd_make_float2([components[0] floatValue], [components[1] floatValue]);
}

simd_float3 UCSimdFloat3FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 3 )
    {
        return simd_make_float3(0, 0, 0);
    }
    return simd_make_float3([components[0] floatValue], [components[1] floatValue], [components[2] floatValue]);
}

simd_float4 UCSimdFloat4FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 4 )
    {
        return simd_make_float4(0, 0, 0, 0);
    }
    return simd_make_float4([components[0] floatValue], [components[1] floatValue], [components[2] floatValue], [components[3] floatValue]);
}

NSArray<NSNumber *> *UCSimdFloat2ToArray(simd_float2 vector)
{
    return [NSArray arrayWithObjects:@(vector.x), @(vector.y), nil];
}

NSArray<NSNumber *> *UCSimdFloat3ToArray(simd_float3 vector)
{
    return [NSArray arrayWithObjects:@(vector.x), @(vector.y), @(vector.z), nil];
}

NSArray<NSNumber *> *UCSimdFloat4ToArray(simd_float4 vector)
{
    return [NSArray arrayWithObjects:@(vector.x), @(vector.y), @(vector.z), @(vector.w), nil];
}

simd_float2 UCSimdFloat2FromArray(NSArray<NSNumber *> *array)
{
    if ( [array count] != 2 )
    {
        return simd_make_float2(0, 0);
    }
    return simd_make_float2([array objectAtIndex:0].floatValue, [array objectAtIndex:1].floatValue);
}

simd_float3 UCSimdFloat3FromArray(NSArray<NSNumber *> *array)
{
    if ( [array count] != 3 )
    {
        return simd_make_float3(0, 0, 0);
    }
    return simd_make_float3([array objectAtIndex:0].floatValue, [array objectAtIndex:1].floatValue, [array objectAtIndex:2].floatValue);
}

simd_float4 UCSimdFloat4FromArray(NSArray<NSNumber *> *array)
{
    if ( [array count] != 4 )
    {
        return simd_make_float4(0, 0, 0, 0);
    }
    return simd_make_float4([array objectAtIndex:0].floatValue, [array objectAtIndex:1].floatValue, [array objectAtIndex:2].floatValue, [array objectAtIndex:3].floatValue);
}

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

NSString *UCFormatFloatWithPercentage(float value)
{
    NSString *(*format)(float, NSInteger) = dlsym(dlopen("/System/Library/PrivateFrameworks/AXCoreUtilities.framework/AXCoreUtilities", RTLD_NOW), "AXFormatFloatWithPercentage");
    return format(value, 0);
}

static CGRect _UEOFrameForRectsWithVariadics(CGRect firstArgument, va_list arguments)
{
    CGRect result = CGRectNull;
    if ( !CGRectIsEmpty(firstArgument) )
    {
        result = firstArgument;
    }

    BOOL done = NO;
    while ( !done )
    {
        CGRect nextArgument = va_arg(arguments, CGRect);
        if ( !CGRectIsEmpty(nextArgument) )
        {
            done = CGRectEqualToRect(nextArgument, __UCRectForRectsSentinel);
            if ( !done )
            {
                if ( CGRectIsEmpty(result) )
                {
                    result = nextArgument;
                }
                else
                {
                    result = CGRectUnion(result, nextArgument);
                }
            }
        }
    }

    return result;
}

CGRect _UCRectForRects(CGRect firstArgument, ...)
{
    va_list args;
    va_start(args, firstArgument);
    CGRect result = _UEOFrameForRectsWithVariadics(firstArgument, args);
    va_end(args);

    return result;
}

CGRect UCUnionRects(NSArray<NSValue *> *rects)
{
    CGRect result = CGRectNull;
    for (NSValue *value in rects)
    {
        CGRect next = [value ucCGRectValue];
        if ( !CGRectIsEmpty(next) )
        {
            if ( CGRectIsEmpty(result) )
            {
                result = next;
            }
            else
            {
                result = CGRectUnion(result, next);
            }
        }
    }
    return result;
}
