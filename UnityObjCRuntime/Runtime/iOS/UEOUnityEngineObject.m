//
//  UEOUnityEngineObject.h
//  UnityObjCRuntime
//
//  Created by Eric Liang on 4/26/23.
//

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
    if ( instanceID == 0 )
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
    else if ( [typeFullName isEqualToString:@"UnityEngine.Canvas"] )
    {
        cls = UEOUnityEngineCanvas.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.RectTransform"] )
    {
        cls = UEOUnityEngineRectTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Renderer"] )
    {
        cls = UEOUnityEngineRenderer.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Sprite"] )
    {
        cls = UEOUnityEngineSprite.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.SpriteRenderer"] )
    {
        cls = UEOUnityEngineSpriteRenderer.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Transform"] )
    {
        cls = UEOUnityEngineTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Text"] )
    {
        cls = UEOUnityEngineUIText.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Image"] )
    {
        cls = UEOUnityEngineUIImage.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Button"] )
    {
        cls = UEOUnityEngineUIButton.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Toggle"] )
    {
        cls = UEOUnityEngineUIToggle.class;
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

- (NSString *)name;
{
    return [self safeCSharpStringForKey:@"name"];
}

- (void)setName:(NSString *)name
{
    return [self safeSetCSharpStringForKey:@"name" value:name];
}

- (void)safeCSharpPerformFunctionForKey:(NSString *)key
{
    UnityEngineObjectSafeCSharpVoidForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (BOOL)safeCSharpBoolForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (int)safeCSharpIntForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpIntForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (float)safeCSharpFloatForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpFloatForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (double)safeCSharpDoubleForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpDoubleForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (simd_float2)safeCSharpVector2ForKey:(NSString *)key
{
    return UEOSimdFloat2FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (simd_float3)safeCSharpVector3ForKey:(NSString *)key
{
    return UEOSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (simd_float4)safeCSharpVector4ForKey:(NSString *)key
{
    return UEOSimdFloat4FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (CGRect)safeCSharpRectForKey:(NSString *)key
{
    return CGRectFromString(TO_NSSTRING(UnityEngineObjectSafeCSharpRectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
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

+ (simd_float2)safeCSharpVector2ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UEOSimdFloat2FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector2ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UEOSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (simd_float4)safeCSharpVector4ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UEOSimdFloat4FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector4ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key)));
}

+ (UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return [UEOUnityEngineObject objectWithID:UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))];
}

- (void)safeSetCSharpBoolForKey:(NSString *)key value:(BOOL)value
{
    UnityEngineObjectSafeSetCSharpBoolForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpFloatForKey:(NSString *)key value:(float)value
{
    UnityEngineObjectSafeSetCSharpFloatForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpVector3ForKey:(NSString *)key value:(simd_float3)value
{
    UnityEngineObjectSafeSetCSharpVector3ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(UEOSimdFloat3ToString(value)));
}

- (void)safeSetCSharpStringForKey:(NSString *)key value:(NSString *)value
{
    UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(value));
}

+ (NSArray<UEOUnityEngineObject *> *)findObjectsOfType:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineObjectFindObjectsOfType_CSharpFunc(FROM_NSSTRING(component)));
    return [[arrayString ueoToNumberArray] ueoMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UEOUnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
