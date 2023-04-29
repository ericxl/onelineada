//
//  SolitaireButtonRoundAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface SolitaireButtonRoundAXElement : UnityAccessibilityNode
@end

@implementation SolitaireButtonRoundAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if ( SAFE_CAST_CLASS(UCUIButton, [self.gameObject getComponent:@"UnityEngine.UI.Button"]) != nil && !SAFE_CAST_CLASS(UCUIButton, [self.gameObject getComponent:@"UnityEngine.UI.Button"]).interactable )
    {
        traits |= UIAccessibilityTraitNotEnabled;
    }
    return traits;
}

- (NSString *)accessibilityLabel
{
    return [self.gameObject.name ucDropFirst:@"Button"];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
