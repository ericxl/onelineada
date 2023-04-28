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

- (CGRect)accessibilityFrame
{
    NSArray<NSString *> *corners = [(UCRectTransform *)[self.gameObject transform] getWorldCorners];
    NSArray<NSArray<NSNumber *> *> *screenCorners = [corners ucMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UCSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UCRectTransform rectUtilityWorldToScreenPoint:nil worldPoint:vector];
        return UCSimdFloat2ToArray(screenCorner);
    }];
    float maxX = [[screenCorners ucMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ucMaxNumber].floatValue;
    float minX = [[screenCorners ucMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ucMinNumber].floatValue;
    float maxY = [[screenCorners ucMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ucMaxNumber].floatValue;
    float minY = [[screenCorners ucMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ucMinNumber].floatValue;

    return RECT_TO_SCREEN_RECT(CGRectMake(minX, UCScreen.height - maxY, maxX - minX, maxY - minY));
}

@end
