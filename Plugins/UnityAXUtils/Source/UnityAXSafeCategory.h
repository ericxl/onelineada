//
//  UnityAXSafeCategory.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import <Foundation/Foundation.h>

extern void UnityAXSafeCategoryInstall(NSString *categoryName);

#define UnityAXDefineSafeCategory(quotedTargetClassName, category) \
    UnityAXDeclareSafeCategory(category) \
    UnityAXDefineDeclaredSafeCategory(quotedTargetClassName, category)

#define UnityAXDeclareSafeCategory(category) \
    __attribute__((visibility("hidden"))) \
    @interface __##category##_super : _UnityAXSafeCategory \
    @end \
    __attribute__((visibility("hidden"))) \
    @interface category : __##category##_super \
    @end

#define UnityAXDefineDeclaredSafeCategory(quotedTargetClassName, category) \
    @implementation __##category##_super \
    @end \
    @implementation category (SafeCategory) \
    + (NSString *)unityAXSafeCategoryTargetClassName \
    { \
        return quotedTargetClassName; \
    } \
    + (void)_initializeUnityAXSafeCategory \
    { \
        [self installUnityAXSafeCategoryOnClassNamed:quotedTargetClassName]; \
    } \
    @end \

@interface _UnityAXSafeCategory : NSObject

// This attempts to install the methods of the subclass as a category on the named class
+ (void)installUnityAXSafeCategoryOnClassNamed:(NSString *)targetClassName;

// Returns the name of the safe category target class
@property (nonatomic, strong, readonly, class) NSString *unityAXSafeCategoryTargetClassName;

@end
