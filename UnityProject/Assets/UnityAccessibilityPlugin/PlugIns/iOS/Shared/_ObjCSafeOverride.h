//
//  _ObjCSafeOverride.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>

@interface _ObjCSafeOverride : NSObject

// This attempts to install the methods of the subclass as a category on the named class
+ (void)installObjCSafeOverrideOnClassNamed:(NSString *)targetClassName;

// Returns the name of the safe category target class
@property (nonatomic, strong, readonly, class) NSString *objCSafeOverrideTargetClassName;

@end

extern void _ObjCSafeOverrideInstall(NSString *categoryName);

#define ObjCDefineSafeOverride(quotedTargetClassName, override) \
    ObjCDeclareSafeOverride(override) \
    ObjCDefineDeclaredSafeOverride(quotedTargetClassName, override)

#define ObjCDeclareSafeOverride(override) \
    __attribute__((visibility("hidden"))) \
    @interface __##override##_super : _ObjCSafeOverride \
    @end \
    __attribute__((visibility("hidden"))) \
    @interface override : __##override##_super \
    @end

#define ObjCDefineDeclaredSafeOverride(quotedTargetClassName, override) \
    @implementation __##override##_super \
    @end \
    @implementation override (SafeOverride) \
    + (NSString *)objCSafeOverrideTargetClassName \
    { \
        return quotedTargetClassName; \
    } \
    + (void)_initializeObjCSafeOverride \
    { \
        [self installObjCSafeOverrideOnClassNamed:quotedTargetClassName]; \
    } \
    @end \
