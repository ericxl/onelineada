//
//  UnityAXSafeCategory.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import <Foundation/Foundation.h>

extern void UnityAXSafeCategoryInstall(NSString *categoryName, NSString *className);

#define UnityAXDefineSafeCategory(category) \
    UnityAXDeclareSafeCategory(category) \
    UnityAXDefineDeclaredSafeCategory(category)

#define UnityAXDeclareSafeCategory(category) \
    __attribute__((visibility("hidden"))) \
    @interface __##category##_super : _UnityAXSafeCategory \
    @end \
    __attribute__((visibility("hidden"))) \
    @interface category : __##category##_super \
    @end

#define UnityAXDefineDeclaredSafeCategory(category) \
    @implementation __##category##_super \
    @end \
    @implementation category (SafeCategory) \
    @end \

@interface _UnityAXSafeCategory : NSObject

// This attempts to install the methods of the subclass as a category on the named class
+ (void)installUnityAXSafeCategoryOnClassNamed:(NSString *)targetClassName;

// Returns the name of the safe category target class
@property (nonatomic, strong, readonly, class) NSString *unityAXSafeCategoryTargetClassName;

@end
