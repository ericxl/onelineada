//
//  SolitairePilePresenterAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitairePilePresenterAXElement : UnityAXElement
@end

@implementation SolitairePilePresenterAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return [self.gameObject name];
}

- (NSString *)accessibilityValue
{
    NSArray<UEOUnityEngineComponent *> *allCards = [[UEOUnityEngineGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
    UEOUnityEngineComponent *card = [allCards ueoFirstObjectUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
        return item.transform.position.x == self.transform.position.x && [item.transform find:@"Front"].gameObject.activeInHierarchy;
    }];
    return [card.gameObject name];
}

- (CGRect)accessibilityFrame
{
    UEOUnityEngineTransform *transform = self.transform;
    UEOUnityEngineSpriteRenderer *spriteRenderer = SAFE_CAST_CLASS(UEOUnityEngineSpriteRenderer, [transform getComponent:@"UnityEngine.SpriteRenderer"]);
    CGRect spriteTextureRect = spriteRenderer.sprite.textureRect;
    simd_float3 screenPos = [UEOUnityEngineCamera.main worldToScreenPoint:transform.position];
    CGFloat width = spriteTextureRect.size.width * transform.localScale.x;
    CGFloat height = spriteTextureRect.size.height * transform.localScale.y;
    CGFloat x = screenPos.x - width / 2.0f;
    CGFloat y = screenPos.y + height / 2.0f;
    CGRect axFrame = CGRectMake(x, UEOUnityEngineScreen.height - y, width, height);
    return RECT_TO_SCREEN_RECT(axFrame);
}

@end
