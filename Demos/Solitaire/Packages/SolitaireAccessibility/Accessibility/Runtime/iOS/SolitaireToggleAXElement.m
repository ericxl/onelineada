//
//  SolitaireToggleAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface SolitaireToggleAXElement : UnityAccessibilityNode
@end

@implementation SolitaireToggleAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits traits = ((uint64_t)1 << 53);
    if ( SAFE_CAST_CLASS(UCUIToggle, [self.gameObject getComponent:@"UnityEngine.UI.Toggle"]).isOn )
    {
        traits |= UIAccessibilityTraitSelected;
    }
    if ( SAFE_CAST_CLASS(UCUIToggle, [self.gameObject getComponent:@"UnityEngine.UI.Toggle"]) != nil && !SAFE_CAST_CLASS(UCUIToggle, [self.gameObject getComponent:@"UnityEngine.UI.Toggle"]).interactable )
    {
        traits |= UIAccessibilityTraitNotEnabled;
    }
    return traits;
}

- (CGPoint)accessibilityActivationPoint
{
    UCTransform *checkmark = [self.transform find:@"Background/Checkmark"].transform;
    return UCCGRectGetCenter([SAFE_CAST_CLASS(UCRectTransform, checkmark) unityAXFrameInScreenSpace]);
}

- (NSString *)accessibilityLabel
{
    return [[[self.transform find:@"Label"] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
