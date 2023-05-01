//
//  UnityViewAccessibility.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/30/23.
//

#import "UnityViewAccessibility.h"
#import <UIKit/UIKit.h>
#import "UnityAXUtils.h"

@interface _AXGameGlue: NSObject
@end
@implementation _AXGameGlue
+ (void)load
{
    UnityAXSafeCategoryInstall(@"UnityViewAccessibility");
}
@end

UnityAXDefineDeclaredSafeCategory(@"UnityView", UnityViewAccessibility)

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