//
//  AccessibilityGlue.m
//  AccessibilityBundle
//
//  Created by Eric Liang on 4/16/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"
#import "UnityAccessibilityNode.h"

@interface _AXLoader: NSObject
@end
@implementation _AXLoader

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_AXLoader addAccessibility];
    });
}

+ (void)addAccessibility
{
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display/Days Survived Label"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display/Days Survived Text"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
}

@end
