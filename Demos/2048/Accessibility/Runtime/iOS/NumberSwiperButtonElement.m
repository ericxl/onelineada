//
//  NumberSwiperButtonElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 4/30/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface NumberSwiperButtonElement : UnityAccessibilityNode
@end

@implementation NumberSwiperButtonElement

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityLabel
{
    return [[self.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

@end
