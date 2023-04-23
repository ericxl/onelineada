#import "UnityEngineBridge.h"

NSArray<NSNumber *> *uebStringToNumberArray(NSString *string)
{
    if ( string == nil )
    {
        return nil;
    }
    // Convert the JSON string to NSData
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];

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

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectFind);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectAddComponent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectGetComponent);
