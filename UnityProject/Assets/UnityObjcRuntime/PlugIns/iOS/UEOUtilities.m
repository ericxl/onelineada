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

@end

@implementation NSArray (UEOExtensions)

- (NSArray *)_ueoMapedObjects:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray new];
    for ( id object in self )
    {
        id mapped = block(object);
        [result addObject:mapped];
    }
    return [result copy];
}

- (NSArray *)_ueoFlatMapedObjects:(id (^)(id))block
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

@end
