//
//  SolitaireInGameLabelAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireInGameLabelAXElement : UnityAXElement
@end

@implementation SolitaireInGameLabelAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}


- (NSString *)accessibilityLabel
{
    return [[[self.transform find:[NSString stringWithFormat:@"Label%@", self.transform.name]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (NSString *)accessibilityValue
{
    return [[[self.transform find:[NSString stringWithFormat:@"Label%@Value", self.transform.name]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (CGRect)accessibilityFrameForGO:(UCGameObject *)gameObject
{
    NSArray<NSString *> *corners = [(UCRectTransform *)[gameObject transform] getWorldCorners];
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

- (CGRect)accessibilityFrame
{
    return [self accessibilityFrameForGO:[self gameObject]];
}

@end
