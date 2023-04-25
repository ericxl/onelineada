#import "UEOBase.h"
#import "UEOUnityEngineObject.h"
#import "UnityEngineObjC.h"

@interface UEOUnityEngineObject()
{
    int _instanceID;
}
@end

@implementation UEOUnityEngineObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], [self safeCSharpStringForKey:@"ToString"]];
}

- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:UEOUnityEngineObject.class] )
    {
        return NO;
    }
    return [(UEOUnityEngineObject *)object instanceID] == self.instanceID;
}

+ (instancetype)objectWithID:(int)instanceID
{
    if ( instanceID == -1 )
    {
        return nil;
    }
    Class cls = UEOUnityEngineObject.class;
    NSString *typeFullName = TO_NSSTRING(UnityEngineObjectTypeFullName_CSharpFunc(instanceID));
    if ( [typeFullName isEqualToString:@"UnityEngine.GameObject"] )
    {
        cls = UEOUnityEngineGameObject.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Camera"] )
    {
        cls = UEOUnityEngineCamera.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.RectTransform"] )
    {
        cls = UEOUnityEngineRectTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Transform"] )
    {
        cls = UEOUnityEngineTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"Apple.Accessibility.UnityAccessibilityNode"] )
    {
        cls = NSClassFromString(@"UEOUnityAccessibilityNodeComponent");
    }
    else
    {
        cls = UEOUnityEngineComponent.class;
    }
    UEOUnityEngineObject *result = [cls new];
    result->_instanceID = instanceID;
    return result;
}

- (int)instanceID
{
    return _instanceID;
}

- (NSString *)typeFullName
{
    return TO_NSSTRING(UnityEngineObjectTypeFullName_CSharpFunc(_instanceID));
}

- (BOOL)safeCSharpBoolForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (int)safeCSharpIntForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpIntForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (simd_float3)safeCSharpVector3ForKey:(NSString *)key
{
    return UEOSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (NSString *)safeCSharpStringForKey:(NSString *)key
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key)));
}

- (UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key
{
    return [UEOUnityEngineObject objectWithID:UnityEngineObjectSafeCSharpObjectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))];
}

+ (BOOL)safeCSharpBoolForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpBoolForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (int)safeCSharpIntForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UEOSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key)));
}

+ (UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return [UEOUnityEngineObject objectWithID:UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))];
}

- (void)safeSetCSharpStringForKey:(NSString *)key value:(NSString *)string
{
    UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(string));
}

+ (NSArray<UEOUnityEngineObject *> *)findObjectsOfType:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineObjectFindObjectsOfType_CSharpFunc(FROM_NSSTRING(component)));
    return [[arrayString _ueoToNumberArray] _ueoMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UEOUnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
