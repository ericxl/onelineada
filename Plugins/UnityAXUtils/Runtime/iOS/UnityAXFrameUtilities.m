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
    UCCanvas *canvas = SAFE_CAST_CLASS(UCCanvas, [self.transform getComponentInParent:@"UnityEngine.Canvas"]);
    UCCamera *camera = [canvas renderMode] != UCCanvasRenderModeScreenSpaceOverlay ? canvas.worldCamera : nil;
    NSArray<NSValue *> *screenCorners = [corners ucMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UCSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UCRectTransform rectUtilityWorldToScreenPoint:camera worldPoint:vector];
        return [NSValue ucValueWithSIMDFloat2:screenCorner];
    }];
    float maxX = [screenCorners ucMaxObjectWithBlock:^NSComparisonResult(NSValue *obj1, NSValue * obj2) {
        return [@(obj1.ucSIMDFloat2Value.x) compare:@(obj2.ucSIMDFloat2Value.x)];
    }].ucSIMDFloat2Value.x;
    float minX = [screenCorners ucMinObjectWithBlock:^NSComparisonResult(NSValue *obj1, NSValue * obj2) {
        return [@(obj1.ucSIMDFloat2Value.x) compare:@(obj2.ucSIMDFloat2Value.x)];
    }].ucSIMDFloat2Value.x;
    float maxY = [screenCorners ucMaxObjectWithBlock:^NSComparisonResult(NSValue *obj1, NSValue * obj2) {
        return [@(obj1.ucSIMDFloat2Value.y) compare:@(obj2.ucSIMDFloat2Value.y)];
    }].ucSIMDFloat2Value.y;
    float minY = [screenCorners ucMinObjectWithBlock:^NSComparisonResult(NSValue *obj1, NSValue * obj2) {
        return [@(obj1.ucSIMDFloat2Value.y) compare:@(obj2.ucSIMDFloat2Value.y)];
    }].ucSIMDFloat2Value.y;

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
