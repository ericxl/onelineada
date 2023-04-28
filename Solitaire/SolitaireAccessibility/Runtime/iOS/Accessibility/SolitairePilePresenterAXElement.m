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
        return [NSString stringWithFormat:@"%@ of diamond", [name ucDropFirst:@"Card_Diamond_"]];
    }
    else if ( [name hasPrefix:@"Card_Heart_"] )
    {
        return [NSString stringWithFormat:@"%@ of heart", [name ucDropFirst:@"Card_Heart_"]];
    }
    else if ( [name hasPrefix:@"Card_Club_"] )
    {
        return [NSString stringWithFormat:@"%@ of club", [name ucDropFirst:@"Card_Club_"]];
    }
    else if ( [name hasPrefix:@"Card_Spade_"] )
    {
        return [NSString stringWithFormat:@"%@ of spade", [name ucDropFirst:@"Card_Spade_"]];
    }
    return name;
}

- (NSValue *)positionForCard:(UCComponent *)card
{
    BOOL(*_AXServerCacheGetPossiblyNilObjectForKey)(id, id *) = dlsym(dlopen("/System/Library/PrivateFrameworks/UIAccessibility.framework/UIAccessibility", RTLD_NOW), "_AXServerCacheGetPossiblyNilObjectForKey");
    NSValue *position = nil;
    if ( _AXServerCacheGetPossiblyNilObjectForKey([NSString stringWithFormat:@"SolitairePositionForCard%d", card.instanceID], &position) )
    {
        return position;
    }
    position = [NSValue ucValueWithSIMDFloat3:card.transform.position];

    void(*_AXServerCacheInsertPossiblyNilObjectForKey)(id, id) = dlsym(dlopen("/System/Library/PrivateFrameworks/UIAccessibility.framework/UIAccessibility", RTLD_NOW), "_AXServerCacheInsertPossiblyNilObjectForKey");
    _AXServerCacheInsertPossiblyNilObjectForKey([NSString stringWithFormat:@"SolitairePositionForCard%d", card.instanceID], position);
    return position;
}

- (NSString *)accessibilityValue
{
    NSArray<UCComponent *> *allCards = [[UCGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
    SolitairePresenterType type = [self solitairePresenterType];
    simd_float3 position = [self.transform position];
    if ( type == SolitairePresenterTypeFoundation )
    {
        UCComponent *card = [allCards ucFirstObjectUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ucSIMDFloat3Value;
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
        NSArray<UCComponent *> *cards = [[allCards ucFilterObjectsUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ucSIMDFloat3Value;
            return itemPos.y == position.y && itemPos.x >= position.x && itemPos.x < 3.2;
        }] sortedArrayUsingComparator:^NSComparisonResult(UCComponent * _Nonnull obj1, UCComponent * _Nonnull obj2) {
            NSComparisonResult result = [@([self positionForCard:obj2].ucSIMDFloat3Value.x) compare:@([self positionForCard:obj1].ucSIMDFloat3Value.x)];
            if ( result == NSOrderedSame )
            {
                result = [@(SAFE_CAST_CLASS(UCSpriteRenderer, [obj1 getComponent:@"UnityEngine.SpriteRenderer"]).sortingOrder) compare: @(SAFE_CAST_CLASS(UCSpriteRenderer, [obj2 getComponent:@"UnityEngine.SpriteRenderer"]).sortingOrder)];
            }
            return result;
        }];
        UCComponent *topCard = [cards firstObject];
        
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
            NSArray *behindCardNames = [[NSArray ucArrayByIgnoringNilElementsWithCount:2, [cards ucSafeObjectAtIndex:1], [cards ucSafeObjectAtIndex:2]] ucMapedObjectsWithBlock:^id _Nonnull(UCComponent * _Nonnull obj) {
                return [self cardLabelForGameObjectName:obj.gameObject.name];
            }];
            return [NSString stringWithFormat:@"%@ on top, %@ behind", [self cardLabelForGameObjectName:topCard.gameObject.name], [behindCardNames componentsJoinedByString:@", "]];
        }
    }
    else
    {
        NSArray<UCComponent *> *cards = [[allCards ucFilterObjectsUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ucSIMDFloat3Value;
            return itemPos.x == position.x && itemPos.y <= position.y;
        }] sortedArrayUsingComparator:^NSComparisonResult(UCComponent * _Nonnull obj1, UCComponent * _Nonnull obj2) {
            return ![@([self positionForCard:obj1].ucSIMDFloat3Value.y) compare:@([self positionForCard:obj2].ucSIMDFloat3Value.y)];
        }];
        NSArray<UCComponent *> *topCards = [cards ucFilterObjectsUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            return [item.transform find:@"Front"].gameObject.activeInHierarchy;
        }];
        if ( cards.count > 0 )
        {
            NSArray *cardNames = [topCards ucMapedObjectsWithBlock:^id _Nonnull(UCComponent * _Nonnull obj) {
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

- (CGRect)accessibilityFrameForTransform:(UCComponent *)component
{
    UCTransform *transform = component.transform;
    UCSpriteRenderer *spriteRenderer = SAFE_CAST_CLASS(UCSpriteRenderer, [transform getComponentInChildren:@"UnityEngine.SpriteRenderer"]);
    CGRect spriteTextureRect = spriteRenderer.sprite.textureRect;
    simd_float3 screenPos = [UCCamera.main worldToScreenPoint:transform.position];
    CGFloat width = spriteTextureRect.size.width * transform.localScale.x;
    CGFloat height = spriteTextureRect.size.height * transform.localScale.y;
    CGFloat x = screenPos.x - width / 2.0f;
    CGFloat y = screenPos.y + height / 2.0f;
    CGRect axFrame = CGRectMake(x, UCScreen.height - y, width, height);
    return RECT_TO_SCREEN_RECT(axFrame);
}

- (CGRect)accessibilityFrame
{
    if ( self.solitairePresenterType == SolitairePresenterTypeTableau )
    {
        simd_float3 position = [self.transform position];
        NSArray<UCComponent *> *allCards = [[UCGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
        NSArray<UCComponent *> *cards = [allCards ucFilterObjectsUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ucSIMDFloat3Value;
            return itemPos.x == position.x && itemPos.y <= position.y;
        }];
        NSArray *rectArray = [cards ucMapedObjectsWithBlock:^id _Nonnull(UCComponent * _Nonnull obj) {
            return [NSValue ucValueWithCGRect:[self accessibilityFrameForTransform:obj]];
        }];
        return UCUnionRects(rectArray);
    }
    else if ( self.solitairePresenterType == SolitairePresenterTypeWaste )
    {
        simd_float3 position = [self.transform position];
        NSArray<UCComponent *> *allCards = [[UCGameObject find:@"/CardPool"].transform getComponentsInChildren:@"Solitaire.Presenters.CardPresenter"];
        NSArray<UCComponent *> *cards = [allCards ucFilterObjectsUsingBlock:^BOOL(UCComponent * _Nonnull item) {
            simd_float3 itemPos = [self positionForCard:item].ucSIMDFloat3Value;
            return itemPos.y == position.y && itemPos.x >= position.x && itemPos.x < 3.2;
        }];
        NSArray *rectArray = [cards ucMapedObjectsWithBlock:^id _Nonnull(UCComponent * _Nonnull obj) {
            return [NSValue ucValueWithCGRect:[self accessibilityFrameForTransform:obj]];
        }];
        return UCRectForRects([self accessibilityFrameForTransform:self.transform], UCUnionRects(rectArray));
    }
    else
    {
        return [self accessibilityFrameForTransform:self.transform];
    }
}

@end
