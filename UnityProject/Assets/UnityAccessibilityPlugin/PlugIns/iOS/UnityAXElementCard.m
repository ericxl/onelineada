//
//  UnityAXElementCard.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UnityAXElementCard.h"
#import "UnityEngineObjC.h"
#import "UnityAccessibilityNode.h"

@implementation UnityAXElementCard

- (NSString *)accessibilityLabel
{
    UEOUnityEngineComponent *characterNameText = SAFE_CAST_CLASS(UEOUnityEngineComponent, [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UEOUnityEngineComponent *cardText = SAFE_CAST_CLASS(UEOUnityEngineComponent, [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    return [NSString stringWithFormat:@"%@, %@", [characterNameText safeCSharpStringForKey:@"text"], [cardText safeCSharpStringForKey:@"text"], nil];
}

- (CGRect)accessibilityFrame
{
    UEOUnityEngineComponent *characterNameText = SAFE_CAST_CLASS(UEOUnityEngineComponent, [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Character Name Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UEOUnityEngineComponent *cardText = SAFE_CAST_CLASS(UEOUnityEngineComponent, [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"UnityEngine.UI.Text"] ?: [[UEOUnityEngineGameObject find:@"/In-world Canvas/Card Description Display/Card Text"] getComponent:@"TMPro.TextMeshProUGUI"]);
    UEOUnityEngineRectTransform *nameTransform = SAFE_CAST_CLASS(UEOUnityEngineRectTransform, characterNameText.transform);
    UEOUnityEngineRectTransform *cardTransform = SAFE_CAST_CLASS(UEOUnityEngineRectTransform, cardText.transform);
    return UEORectForRects([self accessibilityFrameForRectTransform:nameTransform], [self accessibilityFrameForRectTransform:cardTransform]);
}

- (CGRect)accessibilityFrameForRectTransform:(UEOUnityEngineRectTransform *)rectTransform
{
    NSArray<NSString *> *corners = [rectTransform getWorldCorners];
    NSArray<NSArray<NSNumber *> *> *screenCorners = [corners _ueoMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UEOSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UEOUnityEngineRectTransform rectUtilityWorldToScreenPoint:nil worldPoint:vector];
        return UEOSimdFloat2ToArray(screenCorner);
    }];
    float maxX = [[screenCorners _ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] _ueoMaxNumber].floatValue;
    float minX = [[screenCorners _ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] _ueoMinNumber].floatValue;
    float maxY = [[screenCorners _ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] _ueoMaxNumber].floatValue;
    float minY = [[screenCorners _ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] _ueoMinNumber].floatValue;

    return RECT_TO_SCREEN_RECT(CGRectMake(minX, UEOUnityEngineScreen.height - maxY, maxX - minX, maxY - minY));
}

- (BOOL)isAccessibilityElement { return YES; }

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitAdjustable;
}

- (NSString *)accessibilityValue
{
    UEOUnityEngineComponent *left = [[[UEOUnityEngineGameObject find:@"/Card(Clone)"].transform find:@"Left Action Text"] getComponent:@"TMPro.TextMeshPro"];
    UEOUnityEngineComponent *right = [[[UEOUnityEngineGameObject find:@"/Card(Clone)"].transform find:@"Right Action Text"] getComponent:@"TMPro.TextMeshPro"];
    return [NSString stringWithFormat:@"Swipe up for %@, down for %@", [right safeCSharpStringForKey:@"text"], [left safeCSharpStringForKey:@"text"]];
}

- (void)accessibilityIncrement
{
    [[[UEOUnityEngineGameObject find:@"/Card(Clone)"] getComponent:@"DeckSwipe.World.CardBehaviour"] safeCSharpPerformFunctionForKey:@"SwipeRight"];
}

- (void)accessibilityDecrement
{
    [[[UEOUnityEngineGameObject find:@"/Card(Clone)"] getComponent:@"DeckSwipe.World.CardBehaviour"] safeCSharpPerformFunctionForKey:@"SwipeLeft"];
}

@end
