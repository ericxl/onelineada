//
//  AccessibilityGlue.m
//  AccessibilityBundle
//
//  Created by Eric Liang on 4/16/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"
#import "UnityAXElement.h"

@interface _AXLoader: NSObject
@end
@implementation _AXLoader

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_AXLoader addAccessibility];
    });
}

+ (void)addAccessibility
{
    _ObjCSafeOverrideInstall(@"UnityViewAccessibility");
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementText"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementProgressDisplay"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityObjCRuntimeBehaviour *)[[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] addComponent:@"UnityObjCRuntimeBehaviour"] setClassName:@"UnityAXElementCard"];
}

@end
