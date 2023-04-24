//
//  UEOBridge.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOBridge.h"

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectTypeFullName);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectFindObjectsOfType);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKey);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectFind);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectAddComponent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineGameObjectGetComponent);

CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponent);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponents);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentInChildren);
CSHARP_BRIDGE_IMPLEMENTATION(UnityEngineComponentGetComponentsInChildren);
