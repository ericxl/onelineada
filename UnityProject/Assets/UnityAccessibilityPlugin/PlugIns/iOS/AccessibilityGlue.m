//
//  AccessibilityGlue.m
//  AccessibilityBundle
//
//  Created by Eric Liang on 4/16/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"
#import <dlfcn.h>
#import "UnityAXElement.h"

static void loadAX(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ObjCSafeOverrideInstall(@"UnityViewAccessibility");
    });
}

static BOOL isAXOn(void)
{
    Boolean (*axEnabled)(void) = dlsym(dlopen("usr/lib/libAccessibility.dylib", RTLD_NOW), "_AXSApplicationAccessibilityEnabled");
    return axEnabled();
}

static void _axPrefChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if ( isAXOn() )
    {
        loadAX();
    }
}

extern void _InitializeAccessibility(void)
{
    if ( isAXOn() )
    {
        loadAX();
    }
    else
    {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 0, _axPrefChanged, CFSTR("com.apple.accessibility.cache.app.ax"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

