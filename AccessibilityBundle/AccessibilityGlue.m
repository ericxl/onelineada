//
//  AccessibilityGlue.m
//  AccessibilityBundle
//
//  Created by Eric Liang on 4/16/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineAPI.h"

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
//    NSArray<UnityEngineComponent *> *objects = [[NSClassFromString(@"UnityEngineScene") current] findObjectsGetInstanceIDsOfTypeGameObject];
//    for (UnityEngineComponent *gameobject in objects)
//    {
//        if ([gameobject getComponent:@"UnityEngine.UI.Button"] != nil)
//        {
//            [gameobject addComponent:@"Apple.Accessibility.AccessibilityNode"];
//        }
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [UIApplication.sharedApplication windows].firstObject);
//    });
    
}

@end
