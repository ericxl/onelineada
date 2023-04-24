//
//  UEOBridge.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectTypeFullName, const char *, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKey, BOOL, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectFindObjectsOfType, const char *, (const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectGetComponent, int, (int, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponents, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInChildren, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInChildren, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInParent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInParent, const char *, (int, const char *));
