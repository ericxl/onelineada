//
//  UEOUtilities.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUtilities.h"
#import <dlfcn.h>

@implementation NSString (UEOExtensions)

- (NSArray<NSNumber *> *)_ueoToNumberArray
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

- (NSArray<NSString *> *)_ueoToStringArray
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

- (NSString *)_ueoDropLast:(NSString *)substring
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

- (NSArray *)_ueoMapedObjectsWithBlock:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray new];
    for ( id object in self )
    {
        id mapped = block(object);
        [result addObject:mapped];
    }
    return [result copy];
}

- (NSArray *)_ueoFlatMapedObjectsWithBlock:(id (^)(id))block
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

- (id)_ueoMaxObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id maxObject = nil;

    for (id object in self) {
        if (maxObject == nil || block(object, maxObject) == NSOrderedDescending) {
            maxObject = object;
        }
    }

    return maxObject;
}

- (id)_ueoMinObjectWithBlock:(NSComparisonResult (^)(id obj1, id obj2))block
{
    id minObject = nil;

    for (id object in self) {
        if (minObject == nil || block(object, minObject) == NSOrderedAscending) {
            minObject = object;
        }
    }

    return minObject;
}

- (NSNumber *)_ueoMaxNumber
{
    return [self _ueoMaxObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
}
- (NSNumber *)_ueoMinNumber
{
    return [self _ueoMinObjectWithBlock:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ( ![obj1 isKindOfClass:NSNumber.class] || ![obj2 isKindOfClass:NSNumber.class] )
        {
            [NSException raise:NSInternalInconsistencyException format:@"Must be array of numbers"];
        }
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
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
