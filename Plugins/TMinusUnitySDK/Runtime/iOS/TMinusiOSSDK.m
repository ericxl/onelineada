//
//  TMinusiOSSDK.m
//  TMinusiOSSDK
//
//  Created by Eric Liang on 5/6/23.
//

#import <Foundation/Foundation.h>
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

@interface TMinusiOSSDK: NSObject
+ (void)setupWithProjectId:(NSString *)projectId;
+ (JSContext *)jsContext;
@end

@implementation TMinusiOSSDK

+ (JSContext *)jsContext
{
    static dispatch_once_t onceToken;
    static JSContext *_jsContext = nil;
    dispatch_once(&onceToken, ^{
        _jsContext = [[JSContextSoft alloc] initWithVirtualMachine:[[JSVirtualMachineSoft alloc] init]];
    });
    return _jsContext;
}

+ (void)setupWithProjectId:(NSString *)projectId
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _setupConsoleForwarding];
        [self _setupExceptionForwarding];
        [self _setupNativeFunctionInvocation];
        [self _setupObjCHelper];
    });
    if ( projectId.length == 0 )
    {
        [NSException raise:NSGenericException format:@"TMinusiOSSDK: Must provide a valid projectID"];
        return;
    }

    NSURL *url = [NSURL URLWithString:@"http://contentserver.ericxl.repl.co/get_main_app_script"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *jsonBodyDict = @{@"project_id": projectId};
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:NSJSONWritingPrettyPrinted error:&jsonError];
    request.HTTPBody = jsonData;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [NSException raise:NSGenericException format:@"Can't download accessibility script."];
            return;
        }

        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[self jsContext] evaluateScript:responseString];
    }];

    [task resume];
}

+ (void)_setupConsoleForwarding __attribute__((objc_direct))
{
    [[self jsContext] evaluateScript:@"var console = {};"];
    [self jsContext][@"console"][@"log"] = ^(NSString *message){
        NSLog(@"JS Console: %@", message);
    };
}

+ (void)_setupExceptionForwarding __attribute__((objc_direct))
{
    [self jsContext].exceptionHandler = ^(JSContext *context, JSValue *exception) {
        [NSException raise:NSGenericException format:@"context: %@ exception: %@", [context debugDescription], [exception description]];
    };
}

+ (void)_setupObjCHelper __attribute__((objc_direct))
{
    [[self jsContext] evaluateScript:@"var ObjC = {};"];
    [self jsContext][@"ObjC"][@"createClassPair"] = ^(NSString *className, NSString *superClassName){
        Class fakeSuperClass = objc_allocateClassPair(NSClassFromString(superClassName), className.UTF8String, 0);
        objc_registerClassPair(fakeSuperClass);
    };
    [self jsContext][@"ObjC"][@"addProtocolToClass"] = ^(NSString *protocol, NSString *className) {
        class_addProtocol(NSClassFromString(className), NSProtocolFromString(protocol));
    };
    [self jsContext][@"ObjC"][@"addBoolMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
        class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^BOOL(id _self, SEL command) {
            JSValue *returnedValue = [block callWithArguments:@[_self]];
            return returnedValue.toBool;
        }), types.UTF8String);
    };
    [self jsContext][@"ObjC"][@"addIntMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
        class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^int(id _self, SEL command) {
            JSValue *returnedValue = [block callWithArguments:@[_self]];
            return returnedValue.toInt32;
        }), types.UTF8String);
    };
    [self jsContext][@"ObjC"][@"addRectMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
        class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^CGRect(id _self, SEL command) {
            JSValue *returnedValue = [block callWithArguments:@[_self]];
            return returnedValue.toRect;
        }), types.UTF8String);
    };
    [self jsContext][@"ObjC"][@"addStringMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
        class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^NSString *(id _self, SEL command) {
            JSValue *returnedValue = [block callWithArguments:@[_self]];
            return returnedValue.toString;
        }), types.UTF8String);
    };
    [self jsContext][@"ObjC"][@"addArrayMethodToClass"] = ^(NSString *category, NSString *selector, JSValue *block, NSString *types) {
        class_addMethod(NSClassFromString(category), NSSelectorFromString(selector), imp_implementationWithBlock(^NSArray *(id _self, SEL command) {
            JSValue *returnedValue = [block callWithArguments:@[_self]];
            return returnedValue.toArray;
        }), types.UTF8String);
    };
}

+ (void)_setupNativeFunctionInvocation __attribute__((objc_direct))
{
    
    [self jsContext][@"LookupSymbol_Bool"] = ^BOOL(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                BOOL (*func) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = *func;
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"LookupSymbol_Int"] = ^int(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                int (*func) = isFuncPtr ? *((void **)handle) : handle;
                int result = *func;
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"LookupSymbol_Float"] = ^float(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                float (*func) = isFuncPtr ? *((void **)handle) : handle;
                float result = *func;
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"LookupSymbol_Double"] = ^double(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                double (*func) = isFuncPtr ? *((void **)handle) : handle;
                double result = *func;
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"LookupSymbol_Rect"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                CGRect (*func) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = *func;
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"LookupSymbol_CharPtr"] = ^NSString *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                const char * (*func) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = *func;
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"LookupSymbol_Selector"] = ^NSString *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                SEL (*func) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = *func;
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Void"] = ^void(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool"] = ^BOOL(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int"] = ^int(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float"] = ^float(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double"] = ^double(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Rect"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                CGRect (*func)() = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func();
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr"] = ^NSString *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id"] = ^JSValue *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Selector"] = ^NSString *(NSString *symbol) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( YES ) {
                SEL (*func)() = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func();
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Void_Bool0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Id0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                void (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0"] = ^void(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                void (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Bool_Bool0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Id0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                BOOL (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0"] = ^BOOL(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                BOOL (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Int_Bool0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Id0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                int (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0"] = ^int(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                int (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Bool0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Id0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                float (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0"] = ^float(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                float (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Bool0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Id0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                double (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0"] = ^double(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                double (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                CGRect (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                CGRect (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                CGRect (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                CGRect (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                CGRect (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                CGRect (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Bool0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Id0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                const char * (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                const char * (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Bool0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Id0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                id (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0"] = ^JSValue *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                id (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean ) {
                SEL (*func)(BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                SEL (*func)(int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                SEL (*func)(float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber ) {
                SEL (*func)(double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject ) {
                SEL (*func)(CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                SEL (*func)(const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) ) {
                SEL (*func)(id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0"] = ^NSString *(NSString *symbol, JSValue *arg0) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString ) {
                SEL (*func)(SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Void_Bool0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Bool0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Bool0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                void (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Int0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Int0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Float0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Float0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Float0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Double0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Double0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Double0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                void (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Rect0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Rect0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Rect0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                void (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_CharPtr0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                void (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                void (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                void (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                void (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                void (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                void (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                void (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                void (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Bool1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                void (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Int1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Float1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Double1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                void (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Rect1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                void (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_CharPtr1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                void (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Id1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                void (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Selector0_Selector1"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                void (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Bool_Bool0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Bool0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Bool0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                BOOL (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Int0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Int0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Int0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Float0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Float0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Float0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Double0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Double0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Double0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                BOOL (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Rect0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_Rect0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Rect0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                BOOL (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_CharPtr0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                BOOL (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                BOOL (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                BOOL (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                BOOL (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                BOOL (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                BOOL (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                BOOL (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                BOOL (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Bool1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                BOOL (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Int1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Float1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Double1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                BOOL (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Rect1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                BOOL (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_CharPtr1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                BOOL (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Id1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                BOOL (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Selector0_Selector1"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                BOOL (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Int_Bool0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Bool0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Bool0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                int (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Int0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Int0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Int0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Float0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Float0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Float0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Double0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Double0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Double0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                int (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Rect0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_Rect0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Rect0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                int (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_CharPtr0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                int (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                int (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                int (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                int (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                int (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                int (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                int (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                int (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Bool1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                int (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Int1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Float1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Double1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                int (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Rect1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                int (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_CharPtr1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                int (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Id1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                int (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Selector0_Selector1"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                int (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Bool0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Bool0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Bool0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                float (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Int0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Int0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Int0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Float0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Float0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Float0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Double0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Double0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Double0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                float (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Rect0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_Rect0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Rect0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                float (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_CharPtr0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                float (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                float (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                float (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                float (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                float (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                float (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                float (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                float (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Bool1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                float (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Int1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Float1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Double1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                float (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Rect1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                float (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_CharPtr1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                float (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Id1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                float (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Selector0_Selector1"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                float (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Bool0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Bool0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Bool0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                double (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Int0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Int0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Int0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Float0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Float0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Float0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Double0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Double0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Double0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                double (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Rect0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_Rect0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Rect0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                double (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_CharPtr0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                double (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                double (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                double (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                double (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                double (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                double (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                double (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                double (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Bool1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                double (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Int1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Float1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Double1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                double (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Rect1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                double (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_CharPtr1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                double (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Id1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                double (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Selector0_Selector1"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                double (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                CGRect (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                CGRect (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                CGRect (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                CGRect (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Bool0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                CGRect (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Int0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Float0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                CGRect (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                CGRect (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                CGRect (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Double0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                CGRect (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                CGRect (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                CGRect (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                CGRect (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Rect0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                CGRect (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                CGRect (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                CGRect (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_CharPtr0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                CGRect (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                CGRect (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                CGRect (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                CGRect (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                CGRect (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                CGRect (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                CGRect (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                CGRect (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                CGRect (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                CGRect (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                CGRect (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                CGRect (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                CGRect (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Selector0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                CGRect (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Bool0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                const char * (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Int0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Float0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Double0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                const char * (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Rect0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                const char * (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_CharPtr0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                const char * (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                const char * (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                const char * (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                const char * (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                const char * (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                const char * (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                const char * (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                const char * (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                const char * (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                const char * (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                const char * (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                const char * (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                const char * (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Selector0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                const char * (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Bool0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Bool0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Bool0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                id (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Int0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Int0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Int0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Float0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Float0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Float0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Double0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Double0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Double0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                id (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Rect0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_Rect0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Rect0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                id (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_CharPtr0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                id (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                id (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                id (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                id (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                id (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                id (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                id (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                id (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Bool1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                id (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Int1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Float1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Double1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                id (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Rect1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                id (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_CharPtr1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                id (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Id1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                id (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Selector0_Selector1"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                id (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isBoolean ) {
                SEL (*func)(BOOL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                SEL (*func)(BOOL, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                SEL (*func)(BOOL, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isNumber ) {
                SEL (*func)(BOOL, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isObject ) {
                SEL (*func)(BOOL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                SEL (*func)(BOOL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(BOOL, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Bool0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isBoolean && arg1.isString ) {
                SEL (*func)(BOOL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toBool, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                SEL (*func)(int, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(int, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(int, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(int, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                SEL (*func)(int, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(int, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(int, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Int0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(int, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.intValue, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                SEL (*func)(float, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(float, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(float, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(float, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                SEL (*func)(float, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(float, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(float, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Float0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(float, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toNumber.floatValue, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isBoolean ) {
                SEL (*func)(double, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(double, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(double, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isNumber ) {
                SEL (*func)(double, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isObject ) {
                SEL (*func)(double, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(double, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(double, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Double0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString ) {
                SEL (*func)(double, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toDouble, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isBoolean ) {
                SEL (*func)(CGRect, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                SEL (*func)(CGRect, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                SEL (*func)(CGRect, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isNumber ) {
                SEL (*func)(CGRect, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isObject ) {
                SEL (*func)(CGRect, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                SEL (*func)(CGRect, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(CGRect, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Rect0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isObject && arg1.isString ) {
                SEL (*func)(CGRect, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toRect, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                SEL (*func)(const char *, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(const char *, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(const char *, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(const char *, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                SEL (*func)(const char *, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                SEL (*func)(const char *, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_CharPtr0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                SEL (*func)(const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(arg0.toString.UTF8String, NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isBoolean ) {
                SEL (*func)(id, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                SEL (*func)(id, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                SEL (*func)(id, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isNumber ) {
                SEL (*func)(id, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isObject ) {
                SEL (*func)(id, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                SEL (*func)(id, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(id, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString ) {
                SEL (*func)(id, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Bool1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isBoolean ) {
                SEL (*func)(SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Int1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Float1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Double1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isNumber ) {
                SEL (*func)(SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Rect1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isObject ) {
                SEL (*func)(SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_CharPtr1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                SEL (*func)(SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), arg1.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Id1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && (arg1.isString || arg1.isArray || arg1.isDate || arg1.isObject || arg1.isNull || arg1.isUndefined) ) {
                SEL (*func)(SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), ({
          id __value = nil;
          if ( arg1.isString ) { __value = arg1.toString; }
          else if ( arg1.isArray ) { __value = arg1.toArray; }
          else if ( arg1.isDate ) { __value = arg1.toDate; }
          else if ( arg1.isObject || arg1.isNull || arg1.isUndefined ) { __value = arg1.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Selector0_Selector1"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isString && arg1.isString ) {
                SEL (*func)(SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(NSSelectorFromString(arg0.toString), NSSelectorFromString(arg1.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Bool2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Int2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Float2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Double2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Rect2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_CharPtr2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Id2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                void (*func)(int, const char *, id) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Int0_CharPtr1_Selector2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( arg0.isNumber && arg1.isString && arg2.isString ) {
                void (*func)(int, const char *, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(arg0.toNumber.intValue, arg1.toString.UTF8String, NSSelectorFromString(arg2.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Bool2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                void (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Int2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                void (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Float2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                void (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Double2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                void (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Rect2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                void (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_CharPtr2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                void (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Id2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                void (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Void_Id0_Selector1_Selector2"] = ^void(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                void (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return;
            } else { }
        }
        return;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Bool2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                BOOL (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Int2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                BOOL (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Float2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                BOOL (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Double2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                BOOL (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Rect2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                BOOL (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_CharPtr2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                BOOL (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Id2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                BOOL (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Bool_Id0_Selector1_Selector2"] = ^BOOL(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                BOOL (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                BOOL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return result;
            } else { }
        }
        return NO;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Bool2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                int (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Int2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                int (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Float2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                int (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Double2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                int (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Rect2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                int (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_CharPtr2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                int (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Id2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                int (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Int_Id0_Selector1_Selector2"] = ^int(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                int (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                int result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Bool2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                float (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Int2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                float (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Float2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                float (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Double2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                float (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Rect2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                float (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_CharPtr2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                float (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Id2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                float (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Float_Id0_Selector1_Selector2"] = ^float(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                float (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                float result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Bool2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                double (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Int2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                double (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Float2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                double (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Double2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                double (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Rect2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                double (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_CharPtr2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                double (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Id2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                double (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Double_Id0_Selector1_Selector2"] = ^double(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                double (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                double result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return result;
            } else { }
        }
        return 0;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Bool2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                CGRect (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Int2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                CGRect (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Float2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                CGRect (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Double2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                CGRect (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Rect2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                CGRect (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_CharPtr2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                CGRect (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Id2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                CGRect (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Rect_Id0_Selector1_Selector2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                CGRect (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                CGRect result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return [JSValueSoft valueWithRect:result inContext:[self jsContext]];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Bool2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                const char * (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Int2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                const char * (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Float2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                const char * (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Double2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                const char * (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Rect2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                const char * (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_CharPtr2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                const char * (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Id2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                const char * (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_CharPtr_Id0_Selector1_Selector2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                const char * (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                const char * result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return [NSString stringWithUTF8String:result];
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Bool2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                id (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Int2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                id (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Float2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                id (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Double2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                id (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Rect2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                id (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_CharPtr2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                id (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Id2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                id (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Id_Id0_Selector1_Selector2"] = ^JSValue *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                id (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                id result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return result;
            } else { }
        }
        return nil;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Bool2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isBoolean ) {
                SEL (*func)(id, SEL, BOOL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toBool);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Int2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                SEL (*func)(id, SEL, int) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.intValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Float2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                SEL (*func)(id, SEL, float) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toNumber.floatValue);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Double2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isNumber ) {
                SEL (*func)(id, SEL, double) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toDouble);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Rect2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isObject ) {
                SEL (*func)(id, SEL, CGRect) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toRect);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_CharPtr2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                SEL (*func)(id, SEL, const char *) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), arg2.toString.UTF8String);
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Id2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && (arg2.isString || arg2.isArray || arg2.isDate || arg2.isObject || arg2.isNull || arg2.isUndefined) ) {
                SEL (*func)(id, SEL, id) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), ({
          id __value = nil;
          if ( arg2.isString ) { __value = arg2.toString; }
          else if ( arg2.isArray ) { __value = arg2.toArray; }
          else if ( arg2.isDate ) { __value = arg2.toDate; }
          else if ( arg2.isObject || arg2.isNull || arg2.isUndefined ) { __value = arg2.toObject; }
          __value; }));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

    [self jsContext][@"InvokeFunc_Selector_Id0_Selector1_Selector2"] = ^NSString *(NSString *symbol, JSValue *arg0, JSValue *arg1, JSValue *arg2) {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) )
        { } else {
            if ( (arg0.isString || arg0.isArray || arg0.isDate || arg0.isObject || arg0.isNull || arg0.isUndefined) && arg1.isString && arg2.isString ) {
                SEL (*func)(id, SEL, SEL) = isFuncPtr ? *((void **)handle) : handle;
                SEL result = func(({
          id __value = nil;
          if ( arg0.isString ) { __value = arg0.toString; }
          else if ( arg0.isArray ) { __value = arg0.toArray; }
          else if ( arg0.isDate ) { __value = arg0.toDate; }
          else if ( arg0.isObject || arg0.isNull || arg0.isUndefined ) { __value = arg0.toObject; }
          __value; }), NSSelectorFromString(arg1.toString), NSSelectorFromString(arg2.toString));
                return NSStringFromSelector(result);
            } else { }
        }
        return NULL;
    };

}

@end

__attribute__((visibility("default")))
@interface _ObjCSafeCategory : NSObject
+ (void)installObjCSafeCategoryOnClassNamed:(NSString *)targetClassName;
@end

@implementation _ObjCSafeCategory

+ (void)installObjCSafeCategoryOnClassNamed:(NSString *)targetClassName
{
    // make sure we have the class
    Class targetClass = NSClassFromString(targetClassName);

    // get the new instance methods and add them
    unsigned int newCount;
    Method *newMethods = class_copyMethodList(self, &newCount);
    if ( newMethods != NULL && newCount > 0 )
    {
        // iterate the new methods
        unsigned int x;
        for ( x = 0; x < newCount && newMethods[x] != NULL; x++ )
        {
            [self _addObjCCategoryMethod:newMethods[x] toClass:targetClass isClass:NO];
        }
    }
    if ( newMethods != NULL )
    {
        free(newMethods);
    }

    // get the new class methods and add them
    newMethods = class_copyMethodList(object_getClass(self), &newCount);
    if ( newMethods != NULL && newCount > 0 )
    {
        // iterate the new methods
        unsigned int x;
        for ( x = 0; x < newCount && newMethods[x] != NULL; x++ )
        {
            if ( method_getName(newMethods[x]) != @selector(load) )
            {
                [self _addObjCCategoryMethod:newMethods[x] toClass:object_getClass(targetClass) isClass:YES];
            }
        }
    }

    if ( newMethods != NULL )
    {
        free(newMethods);
    }
}

+ (void)_addObjCCategoryMethod:(Method)newMethod toClass:(Class)targetClass isClass:(BOOL)isClass
{
    SEL newSelector = method_getName(newMethod);
    IMP originalIMP = NULL;

    // hold onto the original to create an 'original' version of the message
    Method existingMethod = class_getInstanceMethod(targetClass, newSelector);
    if ( existingMethod != NULL )
    {
        originalIMP = method_getImplementation(existingMethod);
    }

    // Add the new method
    if ( !class_addMethod(targetClass, newSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) )
    {
        // change it if we could not add it
        method_setImplementation(existingMethod, method_getImplementation(newMethod));
    }

    // create the 'original' method
    if ( originalIMP != NULL && existingMethod != NULL )
    {
        // go up two superclasses to make sure there is a class in between self and AXBSafeCategory.
        // It is on the class in between, that we will install the original imp
        Class superClass = class_getSuperclass(self);
        if ( superClass != NULL )
        {
            Class superDuperClass = class_getSuperclass(superClass);
            if ( superDuperClass == [_ObjCSafeCategory class] )
            {
                BOOL add = class_addMethod((isClass ? object_getClass(superClass) : superClass), newSelector, originalIMP, method_getTypeEncoding(existingMethod));
                // if method doesn't exist and try to replace is method exist
                IMP replace = class_replaceMethod((isClass ? object_getClass(superClass) : superClass), newSelector, originalIMP, method_getTypeEncoding(existingMethod));
                if ( !add && replace == nil )
                {
                    // error
                }
            }
        }
    }
}

@end

extern __attribute__((visibility("default"))) void _ObjCSafeCategoryInstall(NSString *categoryName, NSString *className)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ( [NSClassFromString(categoryName) respondsToSelector:@selector(installObjCSafeCategoryOnClassNamed:)] )
    {
        [NSClassFromString(categoryName) performSelector:@selector(installObjCSafeCategoryOnClassNamed:) withObject:className];
    }
#pragma clang diagnostic pop
}
