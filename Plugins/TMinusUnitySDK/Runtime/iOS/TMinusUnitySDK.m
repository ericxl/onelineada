//
//  TMinusUnitySDK.m
//  TMinusUnitySDK
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <JavascriptCore/JavascriptCore.h>

#define CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(name, return_type, params) \
__attribute__((visibility("default"))) return_type(* name##_CSharpFunc) = NULL; \
extern __attribute__((visibility("hidden"))) void _TMinusUnityRegisterCSharpFunc_##name (void *func) { name##_CSharpFunc = func; }

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectTypeFullName, const char *, (int));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectFindObjectsOfType, void, (const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectDestroy, void, (int));

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVoidForKey, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKey, BOOL, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKey, float, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKey, double, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector2ForKey, CGRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKey, CGRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector4ForKey, CGRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpRectForKey, CGRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpColorForKey, CGRect, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKey, int, (int, const char *));

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpBoolForKeyStatic, BOOL, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpIntForKeyStatic, int, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpFloatForKeyStatic, float, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpDoubleForKeyStatic, double, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector2ForKeyStatic, CGRect, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector3ForKeyStatic, CGRect, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpVector4ForKeyStatic, CGRect, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpRectForKeyStatic, CGRect, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpStringForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeCSharpObjectForKeyStatic, int, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpBoolForKey, void, (int, const char *, BOOL));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpIntForKey, void, (int, const char *, int));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpFloatForKey, void, (int, const char *, float));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpDoubleForKey, void, (int, const char *, double));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector2ForKey, void, (int, const char *, CGRect));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector3ForKey, void, (int, const char *, CGRect));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpVector4ForKey, void, (int, const char *, CGRect));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpRectForKey, void, (int, const char *, CGRect));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpColorForKey, void, (int, const char *, CGRect));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpStringForKey, void, (int, const char *, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineObjectSafeSetCSharpObjectForKey, void, (int, const char *, int));

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponents, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponentInChildren, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponentsInChildren, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponentInParent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineComponentGetComponentsInParent, void, (int, const char *));

#pragma mark GameObject

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineGameObjectGetComponent, int, (int, const char *));

#pragma mark Transform

CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineTransformFind, int, (int, const char *));

#pragma mark RectTransform
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineRectTransformGetWorldCorners, void, (int));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineRectTransformUtilityWorldToScreenPoint, CGRect, (int, CGRect));

#pragma mark Scene
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineSceneManagerGetActiveSceneIsLoaded, BOOL, (void));
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineSceneManagerGetActiveSceneName, const char *, (void));

#pragma mark Camera
CSHARP_BRIDGE_INTERFACE_AND_IMPLEMENTATION(UnityEngineCameraWorldToScreenPoint, CGRect, (int, CGRect));

static id _gDataBridge = nil;
extern __attribute__((visibility("hidden"))) void _TMinusUnityDataBridgeClear(void)
{
    _gDataBridge = nil;
}

extern __attribute__((visibility("default"))) id _TMinusUnityCSharpGetLatestData(void)
{
    return _gDataBridge;
}

extern __attribute__((visibility("hidden"))) void _TMinusUnityDataBridgePopulateIntArray(const int* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        [_gDataBridge addObject:@(array[i])];
    }
}

extern __attribute__((visibility("hidden"))) void _TMinusUnityDataBridgePopulateDouble4Array(const CGRect* array, int length)
{
    _gDataBridge = [NSMutableArray new];
    for (int32_t i = 0; i < length; ++i) {
        CGRect rect = array[i];
        [_gDataBridge addObject:[NSValue valueWithBytes:&rect objCType:@encode(CGRect)]];
    }
}

@interface NSObject (TMinusSDKPriv)
+ (void)setupWithProjectId:(NSString *)projectId;
@end
extern __attribute__((visibility("hidden"))) void _TMinusSDKSetupWithProjectId(const char *projectId)
{
    [NSClassFromString(@"TMinusiOSSDK") setupWithProjectId:projectId == NULL ? nil : [NSString stringWithUTF8String:projectId]];
}

@implementation NSValue (UEOGExtensions)

- (CGRect)ucCGRectValue
{
    CGRect result;
    [self getValue:&result size:sizeof(CGRect)];
    return result;
}

@end

@interface UnityAccessibilityNode : NSObject
{
    int _instanceID;
}
+ (instancetype)nodeFromID:(int)instanceID withClassname:(NSString *)axClassName;
@end
@interface NSObject (UnityNodeFrame)
- (CGRect)unitySpaceAccessibilityFrame;
@end

@implementation UnityAccessibilityNode

static NSMutableDictionary<NSNumber *, UnityAccessibilityNode *> *_gNodeMap;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gNodeMap = [NSMutableDictionary new];
        [self _setupUnityAccessibilityNodeHelper:(JSContext *)[NSClassFromString(@"TMinusiOSSDK") valueForKey:@"jsContext"]];
    });
}

+ (void)_setupUnityAccessibilityNodeHelper:(JSContext *)jsContext __attribute__((objc_direct))
{
    [jsContext evaluateScript:@"var UnityAccessibilityNode = {};"];
    jsContext[@"UnityAccessibilityNode"][@"createNode"] = ^id(int instanceID, NSString *className) {
        return [UnityAccessibilityNode nodeFromID:instanceID withClassname:className];
    };
}

+ (instancetype)nodeFromID:(int)instanceID withClassname:(NSString *)axClassName
{
    if ( instanceID == 0 )
    {
        return nil;
    }
    id object = [_gNodeMap objectForKey:@(instanceID)];
    Class cls = NSClassFromString(axClassName);
    if ( object != nil )
    {
        if ( [object class] != cls )
        {
            object = nil;
        }
    }
    if ( object == nil )
    {
        UnityAccessibilityNode *node = [cls new];
        node->_instanceID = instanceID;
        [_gNodeMap setObject:node forKey:@(instanceID)];
        object = node;
    }
    return object;
}

- (CGRect)accessibilityFrame
{
    if ( [self respondsToSelector:@selector(unitySpaceAccessibilityFrame)] )
    {
        CGRect rect = [(UnityAccessibilityNode *)self unitySpaceAccessibilityFrame];
        CGFloat scale = [[UIScreen mainScreen] nativeScale];
        rect.origin.x /= scale;
        rect.origin.y /= scale;
        rect.size.width /= scale;
        rect.size.height /= scale;
        return rect;
    }
    return CGRectZero;
}

@end
