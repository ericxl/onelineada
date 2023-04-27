//
//  UnityEngineAPI.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//


#ifndef Unity_ENGINE_API_h
#define Unity_ENGINE_API_h

#define FROM_NSSTRING(nsstring) (nsstring ? nsstring.UTF8String : NULL)
#define TO_NSSTRING(str) (str ? [NSString stringWithUTF8String:str] : nil)

#define SAFE_CAST_CLASS(cls, obj) \
    ({ \
        id object = obj; \
        cls *__castedObject = [object isKindOfClass:[cls class]] ? object : nil; \
        __castedObject; \
    })

#define RECT_TO_SCREEN_RECT(rect) \
    ({ \
        CGFloat scale = [[UIScreen mainScreen] nativeScale]; \
        CGRect __rect = rect; \
        __rect.origin.x /= scale; \
        __rect.origin.y /= scale; \
        __rect.size.width /= scale; \
        __rect.size.height /= scale; \
        __rect; \
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

#import "UEOUtilities.h"
#import "UEOUnityEngineObject.h"
#import "UEOUnityEngineCamera.h"
#import "UEOUnityEngineCanvas.h"
#import "UEOUnityEngineComponent.h"
#import "UEOUnityEngineGameObject.h"
#import "UEOUnityEngineBehaviour.h"
#import "UEOUnityEngineMonoBehaviour.h"
#import "UEOUnityEngineTransform.h"
#import "UEOUnityEngineRectTransform.h"
#import "UEOUnityEngineRenderer.h"
#import "UEOUnityEngineScene.h"
#import "UEOUnityEngineScreen.h"
#import "UEOUnityEngineSprite.h"
#import "UEOUnityEngineSpriteRenderer.h"

#import "UEOUnityEngineUIText.h"
#import "UEOUnityEngineUIImage.h"
#import "UEOUnityEngineUIButton.h"
#import "UEOUnityEngineUIToggle.h"
#import "UEOUnityEngineUISelectable.h"

#endif /* Unity_ENGINE_API_h */
