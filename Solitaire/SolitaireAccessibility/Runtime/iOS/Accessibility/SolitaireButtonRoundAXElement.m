//
//  SolitaireButtonRoundAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireButtonRoundAXElement : UnityAXElement
@end

@implementation SolitaireButtonRoundAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if ( SAFE_CAST_CLASS(UEOUnityEngineUIButton, [self.gameObject getComponent:@"UnityEngine.UI.Button"]) != nil && !SAFE_CAST_CLASS(UEOUnityEngineUIButton, [self.gameObject getComponent:@"UnityEngine.UI.Button"]).interactable )
    {
        traits |= UIAccessibilityTraitNotEnabled;
    }
    return traits;
}

- (NSString *)accessibilityLabel
{
    return [self.gameObject.name ueoDropFirst:@"Button"];
}

- (CGRect)accessibilityFrame
{
    NSArray<NSString *> *corners = [(UEOUnityEngineRectTransform *)[self.gameObject transform] getWorldCorners];
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

@end
