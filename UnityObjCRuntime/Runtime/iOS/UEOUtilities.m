//
//  UEOUtilities.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectTypeFullName);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectFindObjectsOfType);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVoidForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKeyStatic);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKeyStatic);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpBoolForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpFloatForKey);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpStringForKey);

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

@implementation NSString (UEOExtensions)

- (NSArray<NSNumber *> *)ueoToNumberArray
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

- (NSArray<NSString *> *)ueoToStringArray
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\((.*?)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];

    NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:[matches count]];
    for (NSTextCheckingResult *match in matches) {
        NSString *substring = [self substringWithRange:[match rangeAtIndex:0]];
        [substrings addObject:substring];
    }
    return [substrings copy];
}

- (NSString *)ueoDropLast:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring options:NSBackwardsSearch];
    if ( range.location != NSNotFound && range.location + range.length == self.length ) {
        // Remove the substring
        return [self stringByReplacingCharactersInRange:range withString:@""];
    } else {
        return self;
    }
}

@end

@implementation NSArray (UEOExtensions)

- (NSArray *)ueoFilterObjectsUsingBlock:(BOOL (NS_NOESCAPE ^)(id item, NSUInteger index))filterBlock
{
    if ( filterBlock == nil )
    {
        return [self copy];
    }

    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id __nonnull obj, NSUInteger idx, BOOL *__nonnull stop) {
        if ( filterBlock(obj, idx) )
        {
            [result addObject:obj];
        }
    }];

    return result;
}

- (NSArray *)ueoMapedObjectsWithBlock:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray new];
    for ( id object in self )
    {
        id mapped = block(object);
        [result addObject:mapped];
    }
    return [result copy];
}

- (NSArray *)ueoFlatMapedObjectsWithBlock:(id (^)(id))block
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

- (id)ueoMaxObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id maxObject = nil;

    for (id object in self) {
        if (maxObject == nil || block(object, maxObject) == NSOrderedDescending) {
            maxObject = object;
        }
    }

    return maxObject;
}

- (id)ueoMinObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id minObject = nil;

    for (id object in self) {
        if (minObject == nil || block(object, minObject) == NSOrderedAscending) {
            minObject = object;
        }
    }

    return minObject;
}

- (NSNumber *)ueoMaxNumber
{
    return [self ueoMaxObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
}
- (NSNumber *)ueoMinNumber
{
    return [self ueoMinObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
}

+ (instancetype)ueoArrayByIgnoringNilElementsWithCount:(NSUInteger)elementCount, ...
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

NSString *UEOSimdFloat2ToString(simd_float2 vector)
{
    return [NSString stringWithFormat:@"(%f, %f)", vector[0], vector[1]];
}

simd_float2 UEOSimdFloat2FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 2)
    {
        return simd_make_float2(0, 0);
    }
    return simd_make_float2([components[0] floatValue], [components[1] floatValue]);
}

NSArray<NSNumber *> *UEOSimdFloat2ToArray(simd_float2 vector)
{
    return [NSArray arrayWithObjects:@(vector[0]), @(vector[1]), nil];
}

simd_float2 UEOSimdFloat2FromArray(NSArray<NSNumber *> *array)
{
    if ( [array count] != 2 )
    {
        return simd_make_float2(0, 0);
    }
    return simd_make_float2([array objectAtIndex:0].floatValue, [array objectAtIndex:1].floatValue);
}

NSString *UEOSimdFloat3ToString(simd_float3 vector)
{
    return [NSString stringWithFormat:@"(%f, %f, %f)", vector[0], vector[1], vector[2]];
}

simd_float3 UEOSimdFloat3FromString(NSString *str)
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    NSArray *components = [trimmedString componentsSeparatedByString:@","];
    if ( components.count != 3 )
    {
        return simd_make_float3(0, 0, 0);
    }
    return simd_make_float3([components[0] floatValue], [components[1] floatValue], [components[2] floatValue]);
}

NSArray<NSNumber *> *UEOSimdFloat3ToArray(simd_float3 vector)
{
    return [NSArray arrayWithObjects:@(vector[0]), @(vector[1]), @(vector[2]), nil];
}

simd_float3 UEOSimdFloat3FromArray(NSArray<NSNumber *> *array)
{
    if ( [array count] != 3 )
    {
        return simd_make_float3(0, 0, 0);
    }
    return simd_make_float3([array objectAtIndex:0].floatValue, [array objectAtIndex:1].floatValue, [array objectAtIndex:2].floatValue);
}


NSString *UEOFormatFloatWithPercentage(float value)
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
            done = CGRectEqualToRect(nextArgument, __UEORectForRectsSentinel);
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

CGRect _UEORectForRects(CGRect firstArgument, ...)
{
    va_list args;
    va_start(args, firstArgument);
    CGRect result = _UEOFrameForRectsWithVariadics(firstArgument, args);
    va_end(args);

    return result;
}


@implementation _ObjCSafeOverride

+ (NSString *)objCSafeOverrideTargetClassName
{
    // Safe categories will override this method. We want to return nil here
    // (instead of NSObject) to validate that the safe category was installed
    return nil;
}

+ (void)installObjCSafeOverrideOnClassNamed:(NSString *)targetClassName
{
    // make sure we have the class
    Class targetClass = NSClassFromString(targetClassName);

    // get the new instance methods and add them
    unsigned int newCount;
    Method *newMethods = class_copyMethodList(self, &newCount);
    if ( newMethods != NULL && newCount > 0 )
    {
        // iterate the new methods
        unsigned int x;
        for ( x = 0; x < newCount && newMethods[x] != NULL; x++ )
        {
            [self _addObjCOverrideMethod:newMethods[x] toClass:targetClass isClass:NO];
        }
    }
    if ( newMethods != NULL )
    {
        free(newMethods);
    }

    // get the new class methods and add them
    newMethods = class_copyMethodList(object_getClass(self), &newCount);
    if ( newMethods != NULL && newCount > 0 )
    {
        // iterate the new methods
        unsigned int x;
        for ( x = 0; x < newCount && newMethods[x] != NULL; x++ )
        {
            if ( method_getName(newMethods[x]) != @selector(load) )
            {
                [self _addObjCOverrideMethod:newMethods[x] toClass:object_getClass(targetClass) isClass:YES];
            }
        }
    }

    if ( newMethods != NULL )
    {
        free(newMethods);
    }

    // Give classes a chance to load setups
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL setupExistingObjectsSelector = @selector(objCOverrideSetupExistingObjects);
#pragma clang diagnostic pop
    if ( setupExistingObjectsSelector != NULL && [self respondsToSelector:setupExistingObjectsSelector] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:setupExistingObjectsSelector];
#pragma clang diagnostic pop
    }
}

+ (void)_addObjCOverrideMethod:(Method)newMethod toClass:(Class)targetClass isClass:(BOOL)isClass
{
    SEL newSelector = method_getName(newMethod);
    IMP originalIMP = NULL;

    // hold onto the original to create an 'original' version of the message
    Method existingMethod = class_getInstanceMethod(targetClass, newSelector);
    if ( existingMethod != NULL )
    {
        originalIMP = method_getImplementation(existingMethod);
    }

    // Add the new method
    if ( !class_addMethod(targetClass, newSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) )
    {
        // change it if we could not add it
        method_setImplementation(existingMethod, method_getImplementation(newMethod));
    }

    // create the 'original' method
    if ( originalIMP != NULL && existingMethod != NULL )
    {
        // go up two superclasses to make sure there is a class in between self and AXBSafeCategory.
        // It is on the class in between, that we will install the original imp
        Class superClass = class_getSuperclass(self);
        if ( superClass != NULL )
        {
            Class superDuperClass = class_getSuperclass(superClass);
            if ( superDuperClass == [_ObjCSafeOverride class] )
            {
                BOOL add = class_addMethod((isClass ? object_getClass(superClass) : superClass), newSelector, originalIMP, method_getTypeEncoding(existingMethod));
                // if method doesn't exist and try to replace is method exist
                IMP replace = class_replaceMethod((isClass ? object_getClass(superClass) : superClass), newSelector, originalIMP, method_getTypeEncoding(existingMethod));
                if ( !add && replace == nil )
                {
                    // error
                }
            }
        }
    }
}

@end

void _ObjCSafeOverrideInstall(NSString *categoryName)
{
    Class class = NSClassFromString(categoryName);
    if ( class != nil )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL initializeObjCSafeOverrideSelector = @selector(_initializeObjCSafeOverride);
#pragma clang diagnostic pop
        if ( initializeObjCSafeOverrideSelector != nil && [class respondsToSelector:initializeObjCSafeOverrideSelector] )
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [class performSelector:initializeObjCSafeOverrideSelector];
#pragma clang diagnostic pop
        }
    }
}
