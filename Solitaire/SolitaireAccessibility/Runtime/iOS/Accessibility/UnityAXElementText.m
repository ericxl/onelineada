//
//  UnityAXElementText.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UnityAccessibility.h"

@interface UnityAXElementText : UnityAXElement
@end

@implementation UnityAXElementText

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

- (NSString *)accessibilityValue
{
    id textComponent = [self.gameObject.transform getComponentInChildren:@"UnityEngine.UI.Text"] ?: [self.gameObject.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"];
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
