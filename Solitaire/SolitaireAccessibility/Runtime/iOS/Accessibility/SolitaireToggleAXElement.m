//
//  SolitaireToggleAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireToggleAXElement : UnityAXElement
@end

@implementation SolitaireToggleAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits result = ((uint64_t)1 << 53);
    if ( SAFE_CAST_CLASS(UEOUnityEngineUIToggle, [self.gameObject getComponent:@"UnityEngine.UI.Toggle"]).isOn )
    {
        result |= UIAccessibilityTraitSelected;
    }
    return result;
}

- (CGPoint)accessibilityActivationPoint
{
    UEOUnityEngineGameObject *checkmark = [self.transform find:@"Background/Checkmark"].gameObject;
    return UEOCGRectGetCenter([self accessibilityFrameForGO:checkmark]);
}

- (NSString *)accessibilityLabel
{
    return [[[self.transform find:@"Label"] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (CGRect)accessibilityFrameForGO:(UEOUnityEngineGameObject *)gameObject
{
    NSArray<NSString *> *corners = [(UEOUnityEngineRectTransform *)[gameObject transform] getWorldCorners];
    NSArray<NSArray<NSNumber *> *> *screenCorners = [corners ueoMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UEOSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UEOUnityEngineRectTransform rectUtilityWorldToScreenPoint:nil worldPoint:vector];
        return UEOSimdFloat2ToArray(screenCorner);
    }];
    float maxX = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ueoMaxNumber].floatValue;
    float minX = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ueoMinNumber].floatValue;
    float maxY = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ueoMaxNumber].floatValue;
    float minY = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ueoMinNumber].floatValue;

    return RECT_TO_SCREEN_RECT(CGRectMake(minX, UEOUnityEngineScreen.height - maxY, maxX - minX, maxY - minY));
}

- (CGRect)accessibilityFrame
{
    return [self accessibilityFrameForGO:[self gameObject]];
}

@end
