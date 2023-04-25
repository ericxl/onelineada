//
//  UnityAXElementBarGroup.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UnityAXElementBarGroup.h"
#import "UnityEngineObjC.h"

@implementation UnityAXElementBarGroup

- (CGRect)accessibilityFrame
{
    NSArray<NSString *> *corners = [(UEOUnityEngineRectTransform *)[self.gameObject transform] getWorldCorners];
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

- (NSString *)accessibilityLabel
{
    return [self.component.name _ueoDropLast:@" Bar Group"];
}

- (NSString *)accessibilityValue
{
    id image = [self.component.transform find:[self.component.name _ueoDropLast:@" Group"]];
    UEOUnityEngineUIImage *imageComponent = SAFE_CAST_CLASS(UEOUnityEngineUIImage, [image getComponent:@"UnityEngine.UI.Image"]);
    return UEOFormatFloatWithPercentage(imageComponent.fillAmount);
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

@end
