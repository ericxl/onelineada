//
//  SolitaireMainGameParentAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireMainGameParentAXElement : UnityAXElement
@end

@implementation SolitaireMainGameParentAXElement

- (BOOL)accessibilityElementsHidden
{
    return !SAFE_CAST_CLASS(UCCanvas, [[UCGameObject find:@"/UI/CanvasGameControls"] getComponent:@"UnityEngine.Canvas"]).enabled;
}

- (CGRect)accessibilityFrame
{
    return UIScreen.mainScreen.bounds;
}

- (NSArray *)accessibilityElements
{
    NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:13,
                         [UnityAXElement node:[UCGameObject find:@"/Foundation1"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Foundation2"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Foundation3"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Foundation4"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Waste"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Stock"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau1"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau2"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau3"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau4"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau5"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau6"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UCGameObject find:@"/Tableau7"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")]
    ];
    return [elements _axModaledSorted];
}

@end
