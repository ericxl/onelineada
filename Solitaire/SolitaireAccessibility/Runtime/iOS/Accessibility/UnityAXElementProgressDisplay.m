//
//  UnityAXElementProgressDisplay.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UnityAccessibility.h"

@interface UnityAXElementProgressDisplay : UnityAXElement
@end

@implementation UnityAXElementProgressDisplay

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

- (NSString *)accessibilityValue
{
    id text = [self.gameObject.transform find:@"Days Survived Text"];
    id textComponent = [text getComponentInChildren:@"UnityEngine.UI.Text"] ?: [text getComponentInChildren:@"TMPro.TextMeshProUGUI"];
    return [textComponent safeCSharpStringForKey:@"text"];
}

- (NSString *)accessibilityLabel
{
    id text = [self.gameObject.transform find:@"Days Survived Label"];
    id textComponent = [text getComponentInChildren:@"UnityEngine.UI.Text"] ?: [text getComponentInChildren:@"TMPro.TextMeshProUGUI"];
    return [textComponent safeCSharpStringForKey:@"text"];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitStaticText;
}

@end
