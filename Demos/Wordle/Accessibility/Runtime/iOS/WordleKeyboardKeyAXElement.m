//
//  WordleKeyboardKeyAXElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 5/4/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface WordleKeyboardKeyAXElement : UnityAccessibilityNode
@end

@implementation WordleKeyboardKeyAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    if ( [[[self.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"] isEqualToString:@"SUBMIT"] )
    {
        return UIAccessibilityTraitButton;
    }
    return UIAccessibilityTraitKeyboardKey;
}

- (NSString *)accessibilityLabel
{
    return [[self.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"] ?: @"delete";
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
