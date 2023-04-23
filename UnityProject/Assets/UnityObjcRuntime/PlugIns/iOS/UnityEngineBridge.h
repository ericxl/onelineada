#import <Foundation/Foundation.h>

#define FROM_NSSTRING(nsstring) (nsstring ? nsstring.UTF8String : NULL)
#define TO_NSSTRING(str) (str ? [NSString stringWithUTF8String:str] : nil)

extern NSArray<NSNumber *> *uebStringToNumberArray(NSString *string);

#define CSHARP_BRIDGE_INTERFACE(name, return_type, params) \
typedef return_type(* _CSharpDelegate_##name) params; \
extern _CSharpDelegate_##name name##_CSharpFunc; \
extern void _CSharpRegisterFunc_##name (void *func);

#define CSHARP_BRIDGE_IMPLEMENTATION(name) \
_CSharpDelegate_##name name##_CSharpFunc = NULL; \
void _CSharpRegisterFunc_##name (void *func) { name##_CSharpFunc = func ; }


CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectGetComponent, int, (int, const char *));
