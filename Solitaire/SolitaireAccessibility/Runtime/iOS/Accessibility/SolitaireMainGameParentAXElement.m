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
    return !SAFE_CAST_CLASS(UEOUnityEngineCanvas, [[UEOUnityEngineGameObject find:@"/UI/CanvasGameControls"] getComponent:@"UnityEngine.Canvas"]).enabled;
}

- (CGRect)accessibilityFrame
{
    return UIScreen.mainScreen.bounds;
}

- (NSArray *)accessibilityElements
{
    NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:13,
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Foundation1"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Foundation2"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Foundation3"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Foundation4"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Waste"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Stock"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau1"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau2"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau3"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau4"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau5"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau6"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")],
                         [UnityAXElement node:[UEOUnityEngineGameObject find:@"/Tableau7"] withClass:NSClassFromString(@"SolitairePilePresenterAXElement")]
    ];
    return [elements _axModaledSorted];
}

@end
