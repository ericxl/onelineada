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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_AXLoader addAccessibility];
    });
}

+ (void)addAccessibility
{
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Version Text"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementText"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Bottom Pane/Progress Display"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementProgressDisplay"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Coal Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Food Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Health Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/HUD Canvas/Top Pane/Stats Display/Hope Bar Group"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementBarGroup"];
    [(UEOUnityAccessibilityNodeComponent *)[[UEOUnityEngineGameObject find:@"/Card(Clone)"] addComponent:@"Apple.Accessibility.UnityAccessibilityNode"] setClassName:@"UnityAXElementCard"];
}

@end
