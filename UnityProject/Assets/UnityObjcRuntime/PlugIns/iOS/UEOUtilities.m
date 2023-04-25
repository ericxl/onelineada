//
//  UEOUtilities.m
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUtilities.h"

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
