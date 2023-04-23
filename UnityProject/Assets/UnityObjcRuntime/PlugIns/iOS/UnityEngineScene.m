#import "UnityEngineBridge.h"
#import "UnityEngineScene.h"
#import "UnityEngineComponent.h"

@implementation UnityEngineScene

+ (instancetype)current
{
    return [UnityEngineScene new];
}

- (NSArray<UnityEngineComponent *> *)findObjectsGetInstanceIDsOfTypeGameObject
{
    char *charString = _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject_Func();
    NSArray *numberArray = uebStringToNumberArray(uebToNSString(charString));
    NSMutableArray *result = [NSMutableArray new];
    for (NSNumber *number in numberArray)
    {
        UnityEngineComponent *component = [UnityEngineComponent objectWithID:number.intValue];
        [result addObject:component];
    }
    return [result copy];
}
@end

