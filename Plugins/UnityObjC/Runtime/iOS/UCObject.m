//
//  UCObject.h
//  UnityObjC
//
//  Created by Eric Liang on 4/26/23.
//

#import "UCObject.h"
#import "UnityObjC.h"

@interface UCObject()
{
    int _instanceID;
}
@end

@implementation UCObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], [self safeCSharpStringForKey:@"ToString"]];
}

- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:UCObject.class] )
    {
        return NO;
    }
    return [(UCObject *)object instanceID] == self.instanceID;
}

+ (instancetype)objectWithID:(int)instanceID
{
    if ( instanceID == 0 )
    {
        return nil;
    }
    Class cls = UCObject.class;
    NSString *typeFullName = TO_NSSTRING(UnityEngineObjectTypeFullName_CSharpFunc(instanceID));
    if ( [typeFullName isEqualToString:@"UnityEngine.GameObject"] )
    {
        cls = UCGameObject.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Camera"] )
    {
        cls = UCCamera.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Canvas"] )
    {
        cls = UCCanvas.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.RectTransform"] )
    {
        cls = UCRectTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Renderer"] )
    {
        cls = UCRenderer.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Sprite"] )
    {
        cls = UCSprite.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.SpriteRenderer"] )
    {
        cls = UCSpriteRenderer.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Transform"] )
    {
        cls = UCTransform.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Text"] )
    {
        cls = UCUIText.class;
    }
    else if ( [typeFullName isEqualToString:@"TMPro.TextMeshProUGUI"] )
    {
        cls = UCTMProTextUGUI.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Image"] )
    {
        cls = UCUIImage.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Button"] )
    {
        cls = UCUIButton.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Outline"] )
    {
        cls = UCUIOutline.class;
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.UI.Toggle"] )
    {
        cls = UCUIToggle.class;
    }
    else
    {
        cls = UCComponent.class;
    }
    UCObject *result = [cls new];
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
    return UCSimdFloat2FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (simd_float3)safeCSharpVector3ForKey:(NSString *)key
{
    return UCSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (simd_float4)safeCSharpVector4ForKey:(NSString *)key
{
    return UCSimdFloat4FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (CGRect)safeCSharpRectForKey:(NSString *)key
{
    return CGRectFromString(TO_NSSTRING(UnityEngineObjectSafeCSharpRectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))));
}

- (NSString *)safeCSharpStringForKey:(NSString *)key
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key)));
}

- (UCObject *)safeCSharpObjectForKey:(NSString *)key
{
    return [UCObject objectWithID:UnityEngineObjectSafeCSharpObjectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))];
}

+ (BOOL)safeCSharpBoolForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpBoolForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (int)safeCSharpIntForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (float)safeCSharpFloatForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpFloatForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (double)safeCSharpDoubleForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UnityEngineObjectSafeCSharpDoubleForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key));
}

+ (simd_float2)safeCSharpVector2ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UCSimdFloat2FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector2ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UCSimdFloat3FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector3ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (simd_float4)safeCSharpVector4ForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return UCSimdFloat4FromString(TO_NSSTRING(UnityEngineObjectSafeCSharpVector4ForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (CGRect)safeCSharpRectForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return CGRectFromString(TO_NSSTRING(UnityEngineObjectSafeCSharpRectForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))));
}

+ (NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key)));
}

+ (UCObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType
{
    return [UCObject objectWithID:UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc(FROM_NSSTRING(cSharpType), FROM_NSSTRING(key))];
}

- (void)safeSetCSharpBoolForKey:(NSString *)key value:(BOOL)value
{
    UnityEngineObjectSafeSetCSharpBoolForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpIntForKey:(NSString *)key value:(int)value
{
    UnityEngineObjectSafeSetCSharpIntForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpFloatForKey:(NSString *)key value:(float)value
{
    UnityEngineObjectSafeSetCSharpFloatForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpDoubleForKey:(NSString *)key value:(double)value
{
    UnityEngineObjectSafeSetCSharpDoubleForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), value);
}

- (void)safeSetCSharpVector2ForKey:(NSString *)key value:(simd_float2)value
{
    UnityEngineObjectSafeSetCSharpVector2ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(UCSimdFloat2ToString(value)));
}

- (void)safeSetCSharpVector3ForKey:(NSString *)key value:(simd_float3)value
{
    UnityEngineObjectSafeSetCSharpVector3ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(UCSimdFloat3ToString(value)));
}

- (void)safeSetCSharpVector4ForKey:(NSString *)key value:(simd_float4)value
{
    UnityEngineObjectSafeSetCSharpVector4ForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(UCSimdFloat4ToString(value)));
}

- (void)safeSetCSharpRectForKey:(NSString *)key value:(CGRect)value
{
    UnityEngineObjectSafeSetCSharpRectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(NSStringFromCGRect(value)));
}

- (void)safeSetCSharpStringForKey:(NSString *)key value:(NSString *)value
{
    UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key), FROM_NSSTRING(value));
}

+ (NSArray<UCObject *> *)findObjectsOfType:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineObjectFindObjectsOfType_CSharpFunc(FROM_NSSTRING(component)));
    return [[arrayString ucToNumberArray] ucMapedObjectsWithBlock:^id(NSNumber *obj) {
        return [UCObject objectWithID:obj.intValue];
    }];
}

@end
