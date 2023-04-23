#import "UnityEngineBridge.h"


const char *uebFromNSString(NSString *str)
{
    return str ? str.UTF8String : NULL;
}

NSString *uebToNSString(const char *cString)
{
    return cString ? [NSString stringWithUTF8String:cString] : nil;
}

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

_GameAXDelegate_GameObjectFind _GameAXDelegate_GameObjectFind_Func = NULL;
void _GameAXRegisterFunc_GameObjectFind(void *func) { _GameAXDelegate_GameObjectFind_Func = func; }

_GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject_Func = NULL;
void _GameAXRegisterFunc_FindObjectsGetInstanceIDsOfTypeGameObject(void *func) { _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject_Func = func; }

_GameAXDelegate_GetComponentForObject _GameAXDelegate_GetComponentForObject_Func = NULL;
void _GameAXRegisterFunc_GetComponentForObject(void *func) { _GameAXDelegate_GetComponentForObject_Func = func; }

_GameAXDelegate_AddComponentForObject _GameAXDelegate_AddComponentForObject_Func = NULL;
void _GameAXRegisterFunc_AddComponentForObject(void *func) { _GameAXDelegate_AddComponentForObject_Func = func; }



