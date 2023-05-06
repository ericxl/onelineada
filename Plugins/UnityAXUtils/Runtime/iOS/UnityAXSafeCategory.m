//
//  UnityAXSafeCategory.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import "UnityAXSafeCategory.h"
#import <objc/runtime.h>

@implementation _UnityAXSafeCategory

+ (NSString *)unityAXSafeCategoryTargetClassName
{
    // Safe categories will override this method. We want to return nil here
    // (instead of NSObject) to validate that the safe category was installed
    return nil;
}

+ (void)installUnityAXSafeCategoryOnClassNamed:(NSString *)targetClassName
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
            [self _addUnityAXCategoryMethod:newMethods[x] toClass:targetClass isClass:NO];
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
                [self _addUnityAXCategoryMethod:newMethods[x] toClass:object_getClass(targetClass) isClass:YES];
            }
        }
    }

    if ( newMethods != NULL )
    {
        free(newMethods);
    }

    // Give classes a chance to load setups
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL setupExistingObjectsSelector = @selector(unityAXCategorySetupExistingObjects);
#pragma clang diagnostic pop
    if ( setupExistingObjectsSelector != NULL && [self respondsToSelector:setupExistingObjectsSelector] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:setupExistingObjectsSelector];
#pragma clang diagnostic pop
    }
}

+ (void)_addUnityAXCategoryMethod:(Method)newMethod toClass:(Class)targetClass isClass:(BOOL)isClass
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
            if ( superDuperClass == [_UnityAXSafeCategory class] )
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

void UnityAXSafeCategoryInstall(NSString *categoryName, NSString *className)
{
    Class class = NSClassFromString(categoryName);
    if ( class != nil )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL initializeUnityAXSafeCategorySelector = @selector(installUnityAXSafeCategoryOnClassNamed:);
#pragma clang diagnostic pop
        if ( initializeUnityAXSafeCategorySelector != nil && [class respondsToSelector:initializeUnityAXSafeCategorySelector] )
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [class performSelector:initializeUnityAXSafeCategorySelector withObject:className];
#pragma clang diagnostic pop
        }
    }
}

