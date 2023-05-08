//
//  JavascriptRuntime.m
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import "UnityAXUtils.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import <JavascriptCore/JavascriptCore.h>

#define SOFT_LINK_FRAMEWORK(framework) \
    static void* framework##Library(void) \
    { \
        static dispatch_once_t onceToken; \
        static void* frameworkLibrary = NULL; \
        dispatch_once(&onceToken, ^{ \
            frameworkLibrary = dlopen("/System/Library/Frameworks/" #framework ".framework/" #framework, RTLD_NOW); \
        }); \
        return frameworkLibrary; \
    }

#define SOFT_LINK_CLASS(framework, className) \
    @class className; \
    static Class init##className(void); \
    static Class (*get##className##Class)(void) = init##className; \
    static Class class##className; \
    \
    static Class className##Function(void) \
    { \
        return class##className; \
    } \
    \
    static Class init##className(void) \
    { \
        framework##Library(); \
        class##className = objc_getClass(#className); \
        get##className##Class = className##Function; \
        return class##className; \
    } \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wunused-function\"") \
    static className *alloc##className##Instance(void) \
    { \
        return [get##className##Class() alloc]; \
    } \
    _Pragma("clang diagnostic pop")

SOFT_LINK_FRAMEWORK(JavascriptCore)
SOFT_LINK_CLASS(JavascriptCore, JSVirtualMachine)
#define JSVirtualMachineSoft getJSVirtualMachineClass()
SOFT_LINK_CLASS(JavascriptCore, JSContext)
#define JSContextSoft getJSContextClass()
SOFT_LINK_CLASS(JavascriptCore, JSValue)
#define JSValueSoft getJSValueClass()


@interface _JavascriptRuntimeInstaller: NSObject
@end
@implementation _JavascriptRuntimeInstaller


static JSContext *_gAppJSContext = nil;
static void _setUpJSContextGenerated(JSContext *jsContext) {
    jsContext[@"InvokeFunc_Void"] = ^void(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                void (*func)() = isFuncPtr ? *((void **)handle) : handle;
                func();
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Bool"] = ^BOOL(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                BOOL (*func)() = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func();
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Int"] = ^int(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                int (*func)() = isFuncPtr ? *((void **)handle) : handle;
                int result = func();
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float"] = ^float(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                float (*func)() = isFuncPtr ? *((void **)handle) : handle;
                float result = func();
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double"] = ^double(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                double (*func)() = isFuncPtr ? *((void **)handle) : handle;
                double result = func();
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Vector2"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                simd_float2 (*func)() = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func();
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                simd_float3 (*func)() = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func();
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                simd_float4 (*func)() = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func();
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                CGRect (*func)() = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func();
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr"] = ^NSString *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                const char * (*func)() = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func();
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                id (*func)() = isFuncPtr ? *((void **)handle) : handle;
                id result = func();
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Void_Bool0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                void (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                void (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                void (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                void (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                void (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                void (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                void (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                void (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                void (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                void (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Bool_Bool0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                BOOL (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                BOOL (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                BOOL (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                BOOL (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                BOOL (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                BOOL (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                BOOL (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                BOOL (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                BOOL (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                BOOL (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Int_Bool0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                int (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                int (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                int (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                int (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                int (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                int (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                int (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                int (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                int (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                int (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                float (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                float (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                float (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                float (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                float (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                float (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                float (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                float (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                float (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                float (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                double (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                double (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                double (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                double (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                double (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                double (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                double (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                double (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                double (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                double (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                simd_float2 (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float2 (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float2 (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float2 (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float2 (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float2 (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float2 (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float2 (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                simd_float2 (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float2 (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                simd_float3 (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float3 (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float3 (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float3 (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float3 (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float3 (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float3 (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float3 (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                simd_float3 (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float3 (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                simd_float4 (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float4 (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float4 (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                simd_float4 (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float4 (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float4 (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float4 (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float4 (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                simd_float4 (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                simd_float4 (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                CGRect (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                CGRect (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                const char * (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                const char * (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                const char * (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                const char * (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                const char * (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                const char * (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                const char * (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                const char * (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                const char * (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                const char * (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                id (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                id (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                id (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                id (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                id (*func)(simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                id (*func)(simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                id (*func)(simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                id (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                id (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                id (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                void (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                void (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                void (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                void (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                void (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                void (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                void (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                void (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                void (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Bool0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                void (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                void (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                void (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Float0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                void (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                void (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Double0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                void (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                void (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector20_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                void (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector30_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                void (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Vector40_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                void (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Rect0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                void (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                void (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_CharPtr0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                void (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                void (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Vector21"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Vector31"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Vector41"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Id0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                void (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0, arg1);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                BOOL (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                BOOL (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                BOOL (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                BOOL (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                BOOL (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                BOOL (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                BOOL (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                BOOL (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                BOOL (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Bool0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                BOOL (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                BOOL (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Int0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                BOOL (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Float0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                BOOL (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                BOOL (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Double0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                BOOL (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                BOOL (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector20_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                BOOL (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector30_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                BOOL (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Vector40_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                BOOL (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Rect0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                BOOL (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                BOOL (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_CharPtr0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                BOOL (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                BOOL (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Vector21"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Vector31"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Vector41"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Bool_Id0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                BOOL (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0, arg1);
                return result;
            } else { }
        }
        return NO;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                int (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                int (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                int (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                int (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                int (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                int (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                int (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                int (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                int (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Bool0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                int (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                int (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Int0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                int (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Float0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                int (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                int (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Double0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                int (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                int (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector20_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                int (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector30_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                int (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Vector40_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                int (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Rect0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                int (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                int (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_CharPtr0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                int (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                int (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Vector21"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Vector31"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Vector41"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Int_Id0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                int (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                float (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                float (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                float (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                float (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                float (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                float (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                float (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                float (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                float (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Bool0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                float (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                float (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Int0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                float (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Float0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                float (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                float (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Double0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                float (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                float (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector20_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                float (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector30_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                float (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Vector40_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                float (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Rect0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                float (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                float (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_CharPtr0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                float (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                float (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Vector21"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Vector31"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Vector41"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Float_Id0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                float (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                double (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                double (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                double (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                double (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                double (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                double (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                double (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                double (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                double (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Bool0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                double (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                double (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Int0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                double (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Float0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                double (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                double (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Double0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                double (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                double (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector20_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                double (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector30_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                double (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Vector40_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                double (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Rect0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                double (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                double (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_CharPtr0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                double (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                double (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Vector21"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Vector31"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Vector41"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Double_Id0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                double (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0, arg1);
                return result;
            } else { }
        }
        return 0;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                simd_float2 (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float2 (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float2 (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float2 (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float2 (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float2 (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float2 (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float2 (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                simd_float2 (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float2 (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toBool, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float2 (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float2 (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.intValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float2 (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float2 (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toNumber.floatValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float2 (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float2 (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float2 (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float2 (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toDouble, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float2 (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float2 (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector20_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float2 (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float2 (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector30_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float2 (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float2 (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Vector40_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float2 (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float2 (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toRect, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                simd_float2 (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float2 (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float2 (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float2 (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float2 (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float2 (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float2 (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float2 (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                simd_float2 (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float2 (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0.toString.UTF8String, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float2 (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float2 (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float2 (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector2_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float2 (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float2 result = func(arg0, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                simd_float3 (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float3 (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float3 (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float3 (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float3 (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float3 (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float3 (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float3 (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                simd_float3 (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float3 (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toBool, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float3 (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float3 (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.intValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float3 (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float3 (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toNumber.floatValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float3 (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float3 (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float3 (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float3 (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toDouble, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float3 (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float3 (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector20_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float3 (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float3 (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector30_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float3 (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float3 (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Vector40_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float3 (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float3 (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toRect, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                simd_float3 (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float3 (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float3 (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float3 (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float3 (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float3 (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float3 (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float3 (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                simd_float3 (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float3 (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0.toString.UTF8String, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float3 (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float3 (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float3 (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector3_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float3 (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float3 result = func(arg0, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                simd_float4 (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float4 (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float4 (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                simd_float4 (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float4 (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float4 (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float4 (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float4 (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                simd_float4 (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                simd_float4 (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toBool, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float4 (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float4 (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.intValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float4 (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float4 (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toNumber.floatValue, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                simd_float4 (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                simd_float4 (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                simd_float4 (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                simd_float4 (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toDouble, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float4 (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float4 (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector20_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float4 (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float4 (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector30_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float4 (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float4 (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Vector40_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float4 (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float4 (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toRect, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                simd_float4 (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float4 (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float4 (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                simd_float4 (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float4 (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float4 (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float4 (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float4 (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                simd_float4 (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                simd_float4 (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0.toString.UTF8String, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                simd_float4 (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toBool);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toNumber.intValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                simd_float4 (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toDouble);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toRect);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                simd_float4 (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1.toString.UTF8String);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Vector4_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                simd_float4 (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                simd_float4 result = func(arg0, arg1);
                return [JSValueSoft valueWithObject:@{ @"x":@(result.x), @"y":@(result.y), @"z":@(result.z), @"w":@(result.w) } inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                CGRect (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                CGRect (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector20_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector30_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Vector40_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                CGRect (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                CGRect (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Rect_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0, arg1);
                return [JSValueSoft valueWithRect:result inContext:_gAppJSContext];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                const char * (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                const char * (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                const char * (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                const char * (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                const char * (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                const char * (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                const char * (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                const char * (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                const char * (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Bool0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                const char * (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                const char * (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Int0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                const char * (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Float0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                const char * (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                const char * (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Double0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                const char * (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                const char * (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector20_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                const char * (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector30_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                const char * (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Vector40_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                const char * (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Rect0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                const char * (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                const char * (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_CharPtr0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                const char * (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                const char * (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Vector21"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Vector31"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Vector41"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_CharPtr_Id0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                const char * (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0, arg1);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                id (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                id (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                id (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                id (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                id (*func)(BOOL, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                id (*func)(BOOL, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                id (*func)(BOOL, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                id (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                id (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                id (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                id (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(int, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(int, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(int, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                id (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(float, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(float, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(float, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                id (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                id (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(double, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(double, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(double, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                id (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                id (*func)(simd_float2, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float2, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float2, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float2, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float2, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float2, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(simd_float2, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector20_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float2, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float2(arg0[@"x"].toDouble, arg0[@"y"].toDouble), arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                id (*func)(simd_float3, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float3, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float3, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float3, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float3, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float3, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(simd_float3, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector30_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float3, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float3(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble), arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                id (*func)(simd_float4, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float4, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float4, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(simd_float4, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float4, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float4, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(simd_float4, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Vector40_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(simd_float4, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(simd_make_float4(arg0[@"x"].toDouble, arg0[@"y"].toDouble, arg0[@"z"].toDouble, arg0[@"w"].toDouble), arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                id (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(CGRect, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(CGRect, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(CGRect, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                id (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                id (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                id (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                id (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Vector21"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(id, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, simd_make_float2(arg1[@"x"].toDouble, arg1[@"y"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Vector31"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(id, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, simd_make_float3(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Vector41"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(id, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, simd_make_float4(arg1[@"x"].toDouble, arg1[@"y"].toDouble, arg1[@"z"].toDouble, arg1[@"w"].toDouble));
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Id_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                id (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0, arg1);
                return result;
            } else { }
        }
        return nil;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Bool2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isBoolean ) {
                void (*func)(int, const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toBool);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Int2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isNumber ) {
                void (*func)(int, const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Float2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isNumber ) {
                void (*func)(int, const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Double2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isNumber ) {
                void (*func)(int, const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toDouble);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Vector22"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isObject ) {
                void (*func)(int, const char *, simd_float2) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, simd_make_float2(arg2[@"x"].toDouble, arg2[@"y"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Vector32"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isObject ) {
                void (*func)(int, const char *, simd_float3) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, simd_make_float3(arg2[@"x"].toDouble, arg2[@"y"].toDouble, arg2[@"z"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Vector42"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isObject ) {
                void (*func)(int, const char *, simd_float4) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, simd_make_float4(arg2[@"x"].toDouble, arg2[@"y"].toDouble, arg2[@"z"].toDouble, arg2[@"w"].toDouble));
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Rect2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isObject ) {
                void (*func)(int, const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toRect);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_CharPtr2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isString ) {
                void (*func)(int, const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    jsContext[@"InvokeFunc_Void_Int0_CharPtr1_Id2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isObject ) {
                void (*func)(int, const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, arg2);
                return;
            } else { }
        }
        return;
    };

}

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _gAppJSContext = [[JSContextSoft alloc] initWithVirtualMachine:[[JSVirtualMachineSoft alloc] init]];
        JSContext *jsContext = _gAppJSContext;

        JSValue *jsResult = [jsContext evaluateScript:@"var console = {};"]; // make console an empty object
        jsContext[@"console"][@"log"] = ^(NSString *message){
            NSLog(@"JS Console: %@", message);
        };
        jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            [NSException raise:NSGenericException format:[NSString stringWithFormat:@"context: %@ exception: %@", [context debugDescription], [exception debugDescription]]];
        };
        
        
        _setUpJSContextGenerated(jsContext);
        
        

        [jsContext evaluateScript:@"var ObjC = {};"];
        jsContext[@"ObjC"][@"createClassPair"] = ^(NSString *className, NSString *superClassName){
            Class fakeSuperClass = objc_allocateClassPair(NSClassFromString(superClassName), className.UTF8String, 0);
            objc_registerClassPair(fakeSuperClass);
        };
        jsContext[@"ObjC"][@"addProtocolToClass"] = ^(NSString *protocol, NSString *className) {
            class_addProtocol(NSClassFromString(className), NSProtocolFromString(protocol));
        };
        jsContext[@"ObjC"][@"addBoolMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
            class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^BOOL(id _self, SEL command) {
                JSValue *returnedValue = [block callWithArguments:@[_self]];
                return returnedValue.toBool;
            }), types.UTF8String);
        };
        jsContext[@"ObjC"][@"addStringMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
            class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^NSString *(id _self, SEL command) {
                JSValue *returnedValue = [block callWithArguments:@[_self]];
                return returnedValue.toString;
            }), types.UTF8String);
        };
        [jsContext evaluateScript:@"var Utils = {};"];
        jsContext[@"Utils"][@"installSafeCategory"] = ^(NSString *category, NSString *className) {
//            UnityAXSafeCategoryInstall(category, className);
        };

    //    const char *axLabel = method_getTypeEncoding(class_getInstanceMethod(NSObject.class, @selector(accessibilityLabel)));
        NSError *err;
        NSString *jsScript = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"Data/Raw/accessibility" ofType:@"js"] encoding:NSUTF8StringEncoding error:&err];
        [jsContext evaluateScript:jsScript];
    });

}

@end
