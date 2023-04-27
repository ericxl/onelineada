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
    return CGRectMake(0,0, 100, 100);
}

@end
