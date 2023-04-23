#import <Foundation/Foundation.h>

extern const char *uebFromNSString(NSString *str);

extern NSString *uebToNSString(const char *cString);

extern NSArray<NSNumber *> *uebStringToNumberArray(NSString *string);



typedef int(* _GameAXDelegate_GameObjectFind)(const char *);
extern _GameAXDelegate_GameObjectFind _GameAXDelegate_GameObjectFind_Func;
extern void _GameAXRegisterFunc_GameObjectFind(void *func);

typedef char *(* _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject)(void);
extern _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject_Func;
extern void _GameAXRegisterFunc_FindObjectsGetInstanceIDsOfTypeGameObject(void *func);

typedef int (* _GameAXDelegate_GetComponentForObject)(int, const char *);
extern _GameAXDelegate_GetComponentForObject _GameAXDelegate_GetComponentForObject_Func;
extern void _GameAXRegisterFunc_GetComponentForObject(void *func);

typedef int (* _GameAXDelegate_AddComponentForObject)(int, const char *);
extern _GameAXDelegate_AddComponentForObject _GameAXDelegate_AddComponentForObject_Func;
extern void _GameAXRegisterFunc_AddComponentForObject(void *func);
