//
//  AppleAccessibilitySafeOverride.h
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _AppleAccessibilitySafeOverride : NSObject

// This attempts to install the methods of the subclass as a category on the named class
+ (void)installAppleAccessibilitySafeOverrideOnClassNamed:(NSString *)targetClassName;

// Returns the name of the safe category target class
@property (nonatomic, strong, readonly, class) NSString *appleAccessibilitySafeOverrideTargetClassName;

@end

extern void _AppleAccessibilitySafeOverrideInstall(NSString *categoryName);

#define AppleAccessibilityDefineSafeOverride(quotedTargetClassName, override) \
    AppleAccessibilityDeclareSafeOverride(override) \
    AppleAccessibilityDefineDeclaredSafeOverride(quotedTargetClassName, override)

#define AppleAccessibilityDeclareSafeOverride(override) \
    __attribute__((visibility("hidden"))) \
    @interface __##override##_super : _AppleAccessibilitySafeOverride \
    @end \
    __attribute__((visibility("hidden"))) \
    @interface override : __##override##_super \
    @end

#define AppleAccessibilityDefineDeclaredSafeOverride(quotedTargetClassName, override) \
    @implementation __##override##_super \
    @end \
    @implementation override (SafeOverride) \
    + (NSString *)appleAccessibilitySafeOverrideTargetClassName \
    { \
        return quotedTargetClassName; \
    } \
    + (void)_initializeAppleAccessibilitySafeOverride \
    { \
        [self installAppleAccessibilitySafeOverrideOnClassNamed:quotedTargetClassName]; \
    } \
    @end \
