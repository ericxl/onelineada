//
//  UnityObjC.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#ifndef Unity_OBJC_h
#define Unity_OBJC_h

#define FROM_NSSTRING(nsstring) (nsstring ? nsstring.UTF8String : NULL)
#define TO_NSSTRING(str) (str ? [NSString stringWithUTF8String:str] : nil)

#define FROM_NATIVE_VECTOR2(vector) (simd_make_float2(vector.x, vector.y))
#define TO_NATIVE_VECTOR2(vector) ((NativeVector2){vector.x, vector.y})
#define FROM_NATIVE_VECTOR3(vector) (simd_make_float3(vector.x, vector.y, vector.z))
#define TO_NATIVE_VECTOR3(vector) ((NativeVector3){vector.x, vector.y, vector.z})
#define FROM_NATIVE_VECTOR4(vector) (simd_make_float4(vector.x, vector.y, vector.z, vector.w))
#define TO_NATIVE_VECTOR4(vector) ((NativeVector4){vector.x, vector.y, vector.z, vector.w})
#define FROM_NATIVE_RECT(rect) (CGRectMake(rect.x, rect.y, rect.width, rect.height))
#define TO_NATIVE_RECT(rect) ((NativeRect){rect.origin.x, rect.origin.y, rect.size.width, rect.size.height})
#define FROM_NATIVE_COLOR(color) (simd_make_float4(color.r, color.g, color.b, color.a))
#define TO_NATIVE_COLOR(color) ((NativeColor){color.x, color.y, color.z, color.w})

#define SAFE_CAST_CLASS(cls, obj) \
    ({ \
        id object = obj; \
        cls *__castedObject = [object isKindOfClass:[cls class]] ? object : nil; \
        __castedObject; \
    })

#define CSHARP_BRIDGE_INTERFACE(name, return_type, params) \
typedef return_type(* _CSharpDelegate_##name) params; \
extern _CSharpDelegate_##name name##_CSharpFunc; \
extern void _UEORegisterCSharpFunc_##name (void *func);

#define CSHARP_BRIDGE_IMPLEMENTATION(name) \
_CSharpDelegate_##name name##_CSharpFunc = NULL; \
void _UEORegisterCSharpFunc_##name (void *func) { name##_CSharpFunc = func ; }

#define CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(name, return_type, params) \
typedef return_type(* _CSharpDelegate_##name) params; \
static _CSharpDelegate_##name name##_CSharpFunc = NULL; \
extern void _UEORegisterCSharpFunc_##name (void *func) { name##_CSharpFunc = func ; }

#import "UCUtilities.h"
#import "UCObject.h"
#import "UCCamera.h"
#import "UCCanvas.h"
#import "UCComponent.h"
#import "UCGameObject.h"
#import "UCBehaviour.h"
#import "UCMonoBehaviour.h"
#import "UCTransform.h"
#import "UCRectTransform.h"
#import "UCRenderer.h"
#import "UCScene.h"
#import "UCScreen.h"
#import "UCSprite.h"
#import "UCSpriteRenderer.h"

#import "UCUIText.h"
#import "UCTMProTextUGUI.h"
#import "UCUIImage.h"
#import "UCUIButton.h"
#import "UCUIOutline.h"
#import "UCUIGraphic.h"
#import "UCUIToggle.h"
#import "UCUISelectable.h"

#endif /* Unity_OBJC_h */
