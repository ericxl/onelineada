//
//  SolitaireCanvasGroupAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface WordleBoardAXElement : UnityAccessibilityNode
@end

@implementation WordleBoardAXElement

- (NSArray *)accessibilityElements
{
    NSArray *elements = [[self.transform getComponentsInChildren:@"Tile"] ucMapedObjectsWithBlock:^id(UCComponent *component) {
        return [UnityAccessibilityNode node:component withClass:NSClassFromString(@"WordleTileAXElement")];
    }];
    return elements;
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
