//
//  AccessibilitySettings.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <UIKit/UIKit.h>
#import "UnityEngineObjC.h"
#import <dlfcn.h>

extern BOOL _UnityAccessibility_GetUIKitBoolAnwser(const char *question)
{
    if ( TO_NSSTRING(question) == nil )
    {
        return NO;
    }
    BOOL (*boolFunc)(void) = dlsym(dlopen("/System/Library/Frameworks/UIKit.framework/UIKit", RTLD_NOW), question);
    if ( boolFunc == NULL )
    {
        boolFunc = dlsym(dlopen("/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore", RTLD_NOW), question);
    }
    return boolFunc != NULL ? boolFunc() : NO;
}

extern BOOL _UnityAccessibility_GetUIKitStringAnwser(const char *question)
{
    if ( TO_NSSTRING(question) == nil )
    {
        return NO;
    }
    BOOL (*boolFunc)(void) = dlsym(dlopen("/System/Library/Frameworks/UIKit.framework/UIKit", RTLD_NOW), question);
    if ( boolFunc == NULL )
    {
        boolFunc = dlsym(dlopen("/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore", RTLD_NOW), question);
    }
    return boolFunc != NULL ? boolFunc() : NO;
}
