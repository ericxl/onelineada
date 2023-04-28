//
//  SolitairePilePresenterAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"
#import <dlfcn.h>

typedef CF_ENUM(CFIndex, SolitairePresenterType)
{
    SolitairePresenterTypeFoundation,
    SolitairePresenterTypeWaste,
    SolitairePresenterTypeStock,
    SolitairePresenterTypeTableau,
};

@interface SolitairePilePresenterAXElement : UnityAXElement
@end

@implementation SolitairePilePresenterAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (SolitairePresenterType)solitairePresenterType
{
    if ( [self.gameObject.name containsString:@"Foundation"] )
    {
        return SolitairePresenterTypeFoundation;
    }
    else if ( [self.gameObject.name containsString:@"Waste"] )
    {
        return SolitairePresenterTypeWaste;
    }
    else if ( [self.gameObject.name containsString:@"Stock"] )
    {
        return SolitairePresenterTypeStock;
    }
    else if ( [self.gameObject.name containsString:@"Tableau"] )
    {
        return SolitairePresenterTypeTableau;
    }
    return SolitairePresenterTypeTableau;
}

- (NSString *)accessibilityLabel
{
    return self.gameObject.name;
}

- (NSString *)cardLabelForGameObjectName:(NSString *)name
{
    if ( [name hasPrefix:@"Card_Diamond_"] )
    {
        return [NSString stringWithFormat:@"%@ of diamond", [name ueoDropFirst:@"Card_Diamond_"]];
    }
    else if ( [name hasPrefix:@"Card_Heart_"] )
    {
        return [NSString stringWithFormat:@"%@ of heart", [name ueoDropFirst:@"Card_Heart_"]];
    }
    else if ( [name hasPrefix:@"Card_Club_"] )
    {
        return [NSString stringWithFormat:@"%@ of club", [name ueoDropFirst:@"Card_Club_"]];
    }
    else if ( [name hasPrefix:@"Card_Spade_"] )
    {
        return [NSString stringWithFormat:@"%@ of spade", [name ueoDropFirst:@"Card_Spade_"]];
    }
    return name;
}

- (NSValue *)positionForCard:(UEOUnityEngineComponent *)card
{
    BOOL(*_AXServerCacheGetPossiblyNilObjectForKey)(id, id *) = dlsym(dlopen("/System/Library/PrivateFrameworks/UIAccessibility.framework/UIAccessibility", RTLD_NOW), "_AXServerCacheGetPossiblyNilObjectForKey");
    NSValue *position = nil;
    if ( _AXServerCacheGetPossiblyNilObjectForKey([NSString stringWithFormat:@"SolitairePositionForCard%d", card.instanceID], &position) )
    {
        return position;
    }
    position = [NSValue ueoValueWithSIMDFloat3:card.transform.position];

    void(*_AXServerCacheInsertPossiblyNilObjectForKey)(id, id) = dlsym(dlopen("/System/Library/PrivateFrameworks/UIAccessibility.framework/UIAccessibility", RTLD_NOW), "_AXServerCacheInsertPossiblyNilObjectForKey");
    _AXServerCacheInsertPossiblyNilObjectForKey([NSString stringWithFormat:@"SolitairePositionForCard%d", card.instanceID], position);
    return position;
}

- (NSString *)accessibilityValue
{
    NSArray<UEOUnityEngineComponent *> *allCards = [[UEOUnityEngineGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
    SolitairePresenterType type = [self solitairePresenterType];
    simd_float3 position = [self.transform position];
    if ( type == SolitairePresenterTypeFoundation )
    {
        UEOUnityEngineComponent *card = [allCards ueoFirstObjectUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ueoSIMDFloat3Value;
            return itemPos.x == position.x && itemPos.y == position.y && [item.transform find:@"Front"].gameObject.activeInHierarchy;
        }];
        return [self cardLabelForGameObjectName:card.gameObject.name] ?: @"Empty";
    }
    else if ( type == SolitairePresenterTypeStock )
    {
        return nil;
    }
    else if ( type == SolitairePresenterTypeWaste )
    {
        NSArray<UEOUnityEngineComponent *> *cards = [[allCards ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ueoSIMDFloat3Value;
            return itemPos.y == position.y && itemPos.x >= position.x && itemPos.x < 6.2;
        }] sortedArrayUsingComparator:^NSComparisonResult(UEOUnityEngineComponent * _Nonnull obj1, UEOUnityEngineComponent * _Nonnull obj2) {
            return ![@([self positionForCard:obj1].ueoSIMDFloat3Value.x) compare:@([self positionForCard:obj2].ueoSIMDFloat3Value.x)];
        }];
        UEOUnityEngineComponent *topCard = [cards firstObject];
        
        if ( cards.count == 0 )
        {
            return @"Empty";
        }
        else if ( cards.count == 1 )
        {
            return [self cardLabelForGameObjectName:topCard.gameObject.name];
        }
        else
        {
            NSMutableArray *firstRemoved = [cards mutableCopy];
            [firstRemoved removeObjectAtIndex:0];
            NSArray *behindCardNames = [firstRemoved ueoMapedObjectsWithBlock:^id _Nonnull(UEOUnityEngineComponent * _Nonnull obj) {
                return [self cardLabelForGameObjectName:obj.gameObject.name];
            }];
            return [NSString stringWithFormat:@"%@ on top, %@ behind", [self cardLabelForGameObjectName:topCard.gameObject.name], [behindCardNames componentsJoinedByString:@", "]];
        }
    }
    else
    {
        NSArray<UEOUnityEngineComponent *> *cards = [[allCards ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ueoSIMDFloat3Value;
            return itemPos.x == position.x && itemPos.y <= position.y;
        }] sortedArrayUsingComparator:^NSComparisonResult(UEOUnityEngineComponent * _Nonnull obj1, UEOUnityEngineComponent * _Nonnull obj2) {
            return ![@([self positionForCard:obj1].ueoSIMDFloat3Value.y) compare:@([self positionForCard:obj2].ueoSIMDFloat3Value.y)];
        }];
        NSArray<UEOUnityEngineComponent *> *topCards = [cards ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            return [item.transform find:@"Front"].gameObject.activeInHierarchy;
        }];
        if ( cards.count > 0 )
        {
            NSArray *cardNames = [topCards ueoMapedObjectsWithBlock:^id _Nonnull(UEOUnityEngineComponent * _Nonnull obj) {
                return [self cardLabelForGameObjectName:obj.gameObject.name];
            }];
            NSString *concatLabel = [cardNames componentsJoinedByString:@", "];
            if ( cards.count == topCards.count )
            {
                return [NSString stringWithFormat:@"%@ on top", concatLabel];
            }
            else
            {
                return [NSString stringWithFormat:@"%@ on top, %lu cards behind", concatLabel, (cards.count - topCards.count)];
            }
        }
        else
        {
            return @"Empty";
        }
    }
}

- (CGRect)accessibilityFrameForTransform:(UEOUnityEngineComponent *)component
{
    UEOUnityEngineTransform *transform = component.transform;
    UEOUnityEngineSpriteRenderer *spriteRenderer = SAFE_CAST_CLASS(UEOUnityEngineSpriteRenderer, [transform getComponentInChildren:@"UnityEngine.SpriteRenderer"]);
    CGRect spriteTextureRect = spriteRenderer.sprite.textureRect;
    simd_float3 screenPos = [UEOUnityEngineCamera.main worldToScreenPoint:transform.position];
    CGFloat width = spriteTextureRect.size.width * transform.localScale.x;
    CGFloat height = spriteTextureRect.size.height * transform.localScale.y;
    CGFloat x = screenPos.x - width / 2.0f;
    CGFloat y = screenPos.y + height / 2.0f;
    CGRect axFrame = CGRectMake(x, UEOUnityEngineScreen.height - y, width, height);
    return RECT_TO_SCREEN_RECT(axFrame);
}

- (CGRect)accessibilityFrame
{
    if ( self.solitairePresenterType == SolitairePresenterTypeTableau )
    {
        simd_float3 position = [self.transform position];
        NSArray<UEOUnityEngineComponent *> *allCards = [[UEOUnityEngineGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
        NSArray<UEOUnityEngineComponent *> *cards = [allCards ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ueoSIMDFloat3Value;
            return itemPos.x == position.x && itemPos.y <= position.y;
        }];
        NSArray *rectArray = [cards ueoMapedObjectsWithBlock:^id _Nonnull(UEOUnityEngineComponent * _Nonnull obj) {
            return [NSValue ueoValueWithCGRect:[self accessibilityFrameForTransform:obj]];
        }];
        return UEOUnionRects(rectArray);
    }
    else if ( self.solitairePresenterType == SolitairePresenterTypeWaste )
    {
        simd_float3 position = [self.transform position];
        NSArray<UEOUnityEngineComponent *> *allCards = [[UEOUnityEngineGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
        NSArray<UEOUnityEngineComponent *> *cards = [allCards ueoFilterObjectsUsingBlock:^BOOL(UEOUnityEngineComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ueoSIMDFloat3Value;
            return itemPos.y == position.y && itemPos.x >= position.x && itemPos.x < 3.2;
        }];
        NSArray *rectArray = [cards ueoMapedObjectsWithBlock:^id _Nonnull(UEOUnityEngineComponent * _Nonnull obj) {
            return [NSValue ueoValueWithCGRect:[self accessibilityFrameForTransform:obj]];
        }];
        return UEORectForRects([self accessibilityFrameForTransform:self.transform], UEOUnionRects(rectArray));
    }
    else
    {
        return [self accessibilityFrameForTransform:self.transform];
    }
}

@end
