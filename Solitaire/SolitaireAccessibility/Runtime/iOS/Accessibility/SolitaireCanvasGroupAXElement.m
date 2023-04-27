//
//  SolitaireCanvasGroupAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireCanvasGroupAXElement : UnityAXElement
@end

@implementation SolitaireCanvasGroupAXElement

- (BOOL)accessibilityElementsHidden
{
    return !SAFE_CAST_CLASS(UEOUnityEngineCanvas, [self.gameObject getComponent:@"UnityEngine.Canvas"]).enabled;
}

- (NSArray *)accessibilityElements
{
    if ( [self.gameObject.name isEqualToString:@"CanvasHome"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:5,
                             [UnityAXElement node:[self.transform find:@"Logo"] withClass:NSClassFromString(@"SolitaireLogoAXElement")],
                              [UnityAXElement node:[self.transform find:@"ButtonNewMatch"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                              [UnityAXElement node:[self.transform find:@"ButtonContinue"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                              [UnityAXElement node:[self.transform find:@"ButtonOptions"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                              [UnityAXElement node:[self.transform find:@"ButtonLeaderboard"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasGameInfo"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:2,
                             [UnityAXElement node:[self.transform find:@"Points"] withClass:NSClassFromString(@"SolitaireInGameLabelAXElement")],
                             [UnityAXElement node:[self.transform find:@"Moves"] withClass:NSClassFromString(@"SolitaireInGameLabelAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasGameControls"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:6,
                             [UnityAXElement node:[self.transform find:@"ButtonOptions"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"ButtonHome"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"ButtonMatch"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"ButtonUndo"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"ButtonHint"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"ButtonLeaderboard"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupMatch"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:4,
                             [UnityAXElement node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAXElement node:[self.transform find:@"Background/ButtonRestart"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                             [UnityAXElement node:[self.transform find:@"Background/ButtonNewMatch"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                             [UnityAXElement node:[self.transform find:@"Background/ButtonContinue"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupOptions"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:4,
                             [UnityAXElement node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAXElement node:[self.transform find:@"Background/ButtonClose"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"Background/ToggleDraw"] withClass:NSClassFromString(@"SolitaireToggleAXElement")],
                             [UnityAXElement node:[self.transform find:@"Background/ToggleAudio"] withClass:NSClassFromString(@"SolitaireToggleAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupLeaderboard"] )
    {
        NSArray *elements = [NSArray ueoArrayByIgnoringNilElementsWithCount:3,
                             [UnityAXElement node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAXElement node:[self.transform find:@"Background/ButtonClose"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAXElement node:[self.transform find:@"Background/LabelEmpty"] withClass:NSClassFromString(@"UnityAXElementText")]
        ];
        return [elements _axModaledSorted];
    }
    return nil;
}

- (BOOL)accessibilityViewIsModal
{
    return [self.gameObject.name containsString:@"Popup"];
}

- (CGRect)accessibilityFrame
{
    NSArray<NSString *> *corners = [(UEOUnityEngineRectTransform *)[self.gameObject transform] getWorldCorners];
    NSArray<NSArray<NSNumber *> *> *screenCorners = [corners ueoMapedObjectsWithBlock:^id _Nonnull(NSString * _Nonnull obj) {
        simd_float3 vector = UEOSimdFloat3FromString(obj);
        simd_float2 screenCorner = [UEOUnityEngineRectTransform rectUtilityWorldToScreenPoint:nil worldPoint:vector];
        return UEOSimdFloat2ToArray(screenCorner);
    }];
    float maxX = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ueoMaxNumber].floatValue;
    float minX = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:0];
    }] ueoMinNumber].floatValue;
    float maxY = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ueoMaxNumber].floatValue;
    float minY = [[screenCorners ueoMapedObjectsWithBlock:^id _Nonnull(NSArray<NSNumber *> * _Nonnull obj) {
        return [obj objectAtIndex:1];
    }] ueoMinNumber].floatValue;

    return RECT_TO_SCREEN_RECT(CGRectMake(minX, UEOUnityEngineScreen.height - maxY, maxX - minX, maxY - minY));
}

@end
