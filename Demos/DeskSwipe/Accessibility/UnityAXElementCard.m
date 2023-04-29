//
//  UnityAXElementCard.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface UnityAXElementCard : UnityAccessibilityNode
@end

@implementation UnityAXElementCard

- (NSString *)accessibilityLabel
{
    UCComponent *characterNameText = SAFE_CAST_CLASS(UCComponent, [[UCGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UCGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UCComponent *cardText = SAFE_CAST_CLASS(UCComponent, [[UCGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UCGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    return [NSString stringWithFormat:@"%@, %@", [characterNameText safeCSharpStringForKey:@"text"], [cardText safeCSharpStringForKey:@"text"], nil];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    UCComponent *characterNameText = SAFE_CAST_CLASS(UCComponent, [[UCGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UCGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UCComponent *cardText = SAFE_CAST_CLASS(UCComponent, [[UCGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UCGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UCRectTransform *nameTransform = SAFE_CAST_CLASS(UCRectTransform, characterNameText.transform);
    UCRectTransform *cardTransform = SAFE_CAST_CLASS(UCRectTransform, cardText.transform);
    return UCRectForRects([nameTransform unityAXFrameInScreenSpace], [cardTransform unityAXFrameInScreenSpace]);
}

- (BOOL)isAccessibilityElement { return YES; }

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitAdjustable;
}

- (NSString *)accessibilityValue
{
    UCComponent *left = [[[UCGameObject find:@"/Card(Clone)"].transform find:@"Left Action Text"] getComponent:@"TMPro.TextMeshPro"];
    UCComponent *right = [[[UCGameObject find:@"/Card(Clone)"].transform find:@"Right Action Text"] getComponent:@"TMPro.TextMeshPro"];
    return [NSString stringWithFormat:@"Swipe up for %@, down for %@", [right safeCSharpStringForKey:@"text"], [left safeCSharpStringForKey:@"text"]];
}

- (void)accessibilityIncrement
{
    [[[UCGameObject find:@"/Card(Clone)"] getComponent:@"DeckSwipe.World.CardBehaviour"] safeCSharpPerformFunctionForKey:@"SwipeRight"];
}

- (void)accessibilityDecrement
{
    [[[UCGameObject find:@"/Card(Clone)"] getComponent:@"DeckSwipe.World.CardBehaviour"] safeCSharpPerformFunctionForKey:@"SwipeLeft"];
}

@end
