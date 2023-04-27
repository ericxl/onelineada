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
