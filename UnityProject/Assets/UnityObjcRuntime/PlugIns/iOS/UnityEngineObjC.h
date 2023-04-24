//
//  UnityEngineAPI.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#define FROM_NSSTRING(nsstring) (nsstring ? nsstring.UTF8String : NULL)
#define TO_NSSTRING(str) (str ? [NSString stringWithUTF8String:str] : nil)

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

#import "UEOBridge.h"
#import "UEOUtilities.h"
#import "UEOUnityEngineObject.h"
#import "UEOUnityEngineComponent.h"
#import "UEOUnityEngineGameObject.h"
#import "UEOUnityEngineScene.h"
