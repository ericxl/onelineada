//
//  NSArray+UnityAXUtils.m
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import "NSArray+UnityAXUtils.h"

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

