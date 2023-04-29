//
//  UnityAXFrameUtilities.m
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import "UnityAXFrameUtilities.h"
#import <UIKit/UIKit.h>
#import "UnityAXUtils.h"

@implementation UCRectTransform (FrameExtensions)

- (CGRect)unityAXFrameInScreenSpace
{
    NSArray<NSString *> *corners = [self getWorldCorners];
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

    return CGRectMake(minX, UCScreen.height - maxY, maxX - minX, maxY - minY);
}

@end

@implementation UCSpriteRenderer (FrameExtensions)

- (CGRect)unityAXFrameInScreenSpace
{
    CGRect spriteTextureRect = self.sprite.textureRect;
    UCTransform *transform = self.transform;
    simd_float3 screenPos = [UCCamera.main worldToScreenPoint:transform.position];
    simd_float3 localScale = transform.localScale;
    CGFloat width = spriteTextureRect.size.width * localScale.x;
    CGFloat height = spriteTextureRect.size.height * localScale.y;
    CGFloat x = screenPos.x - width / 2.0f;
    CGFloat y = screenPos.y + height / 2.0f;
    return CGRectMake(x, UCScreen.height - y, width, height);
}

@end
