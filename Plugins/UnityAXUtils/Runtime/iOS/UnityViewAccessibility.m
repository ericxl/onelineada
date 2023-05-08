//
//  UnityViewAccessibility.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/30/23.
//

#import "UnityViewAccessibility.h"
#import <UIKit/UIKit.h>
#import "UnityAXUtils.h"

__attribute__((visibility("hidden")))
@interface _UnityViewAccessibilityInstaller: NSObject
@end
@implementation _UnityViewAccessibilityInstaller
+ (void)load
{
    UnityAXSafeCategoryInstall(@"UnityViewAccessibility", @"UnityView");
}
@end

UnityAXDefineDeclaredSafeCategory(UnityViewAccessibility)

@implementation UnityViewAccessibility

- (BOOL)isAccessibilityElement
{
    return NO;
}

// by default Unity engine sets this to direct touch container, so we need to reset
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitNone;
}

- (NSArray *)accessibilityElements
{
    if ( _UEOCSharpFunctionsRegistrationCompleted() && [UCScene activeSceneIsLoaded] )
    {
        if ( [self respondsToSelector:@selector(unityViewAccessibilityElements)] )
        {
            return [self unityViewAccessibilityElements];
        }
    }
    return [super accessibilityElements];
}

@end
