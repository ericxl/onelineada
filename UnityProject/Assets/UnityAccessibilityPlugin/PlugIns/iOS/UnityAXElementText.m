//
//  UnityAXElementText.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UnityAXElementText.h"
#import "UnityEngineObjC.h"

@implementation UnityAXElementText

- (CGRect)accessibilityFrame
{
    NSArray<NSString *> *corners = [(UEOUnityEngineRectTransform *)[self.gameObject transform] getWorldCorners];
    NSArray<NSArray<NSNumber *> *> *screenCorners = [corners _ueoMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UEOSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UEOUnityEngineRectTransform rectUtilityWorldToScreenPoint:nil worldPoint:vector];
        return UEOSimdFloat2ToArray(screenCorner);
    }];
    float maxX = [[screenCorners _ueoMaxObjectWithBlock:^NSComparisonResult(NSArray<NSNumber *> * _Nonnull obj1, NSArray<NSNumber *> * _Nonnull obj2) {
        return [[obj1 objectAtIndex:0] compare:[obj2 objectAtIndex:0]];
    }] objectAtIndex:0].floatValue;
    float minX = [[screenCorners _ueoMinObjectWithBlock:^NSComparisonResult(NSArray<NSNumber *> * _Nonnull obj1, NSArray<NSNumber *> * _Nonnull obj2) {
        return [[obj1 objectAtIndex:0] compare:[obj2 objectAtIndex:0]];
    }] objectAtIndex:0].floatValue;
    float maxY = [[screenCorners _ueoMaxObjectWithBlock:^NSComparisonResult(NSArray<NSNumber *> * _Nonnull obj1, NSArray<NSNumber *> * _Nonnull obj2) {
        return [[obj1 objectAtIndex:1] compare:[obj2 objectAtIndex:1]];
    }] objectAtIndex:1].floatValue;
    float minY = [[screenCorners _ueoMinObjectWithBlock:^NSComparisonResult(NSArray<NSNumber *> * _Nonnull obj1, NSArray<NSNumber *> * _Nonnull obj2) {
        return [[obj1 objectAtIndex:1] compare:[obj2 objectAtIndex:1]];
    }] objectAtIndex:1].floatValue;

    return RECT_TO_SCREEN_RECT(CGRectMake(minX, UEOUnityEngineScreen.height - maxY, maxX - minX, maxY - minY));
}

- (NSString *)accessibilityValue
{
    id textComponent = [self.component getComponentInChildren:@"UnityEngine.UI.Text"] ?: [self.component getComponentInChildren:@"TMPro.TextMeshProUGUI"];
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
