//
//  UEOBridge.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOBase.h"

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectTypeFullName, const char *, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKey, BOOL, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKey, float, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKey, double, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKeyStatic, BOOL, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKeyStatic, int, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKeyStatic, float, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKeyStatic, double, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKeyStatic, int, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpStringForKey, void, (int, const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectFindObjectsOfType, const char *, (const char *));


CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponents, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInChildren, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInChildren, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInParent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInParent, const char *, (int, const char *));

#pragma mark GameObject

CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectGetComponent, int, (int, const char *));

#pragma mark RectTransform
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformGetWorldCorners, const char *, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformUtilityWorldToScreenPoint, const char *, (int, const char *));
