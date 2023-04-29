//
//  SolitaireCanvasGroupAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface SolitaireCanvasGroupAXElement : UnityAccessibilityNode
@end

@implementation SolitaireCanvasGroupAXElement

- (BOOL)isVisible
{
    return [super isVisible] && SAFE_CAST_CLASS(UCCanvas, [self.gameObject getComponent:@"UnityEngine.Canvas"]).enabled;
}

- (NSArray *)accessibilityElements
{
    if ( [self.gameObject.name isEqualToString:@"CanvasHome"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:5,
                             [UnityAccessibilityNode node:[self.transform find:@"Logo"] withClass:NSClassFromString(@"SolitaireLogoAXElement")],
                              [UnityAccessibilityNode node:[self.transform find:@"ButtonNewMatch"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                              [UnityAccessibilityNode node:[self.transform find:@"ButtonContinue"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                              [UnityAccessibilityNode node:[self.transform find:@"ButtonOptions"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                              [UnityAccessibilityNode node:[self.transform find:@"ButtonLeaderboard"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasGameInfo"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:2,
                             [UnityAccessibilityNode node:[self.transform find:@"Points"] withClass:NSClassFromString(@"SolitaireInGameLabelAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Moves"] withClass:NSClassFromString(@"SolitaireInGameLabelAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasGameControls"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:6,
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonOptions"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonHome"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonMatch"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonUndo"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonHint"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"ButtonLeaderboard"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupMatch"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:4,
                             [UnityAccessibilityNode node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ButtonRestart"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ButtonNewMatch"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ButtonContinue"] withClass:NSClassFromString(@"SolitaireButtonRectAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupOptions"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:4,
                             [UnityAccessibilityNode node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ButtonClose"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ToggleDraw"] withClass:NSClassFromString(@"SolitaireToggleAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ToggleAudio"] withClass:NSClassFromString(@"SolitaireToggleAXElement")]
        ];
        return [elements _axModaledSorted];
    }
    else if ( [self.gameObject.name isEqualToString:@"CanvasPopupLeaderboard"] )
    {
        NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:3,
                             [UnityAccessibilityNode node:[self.transform find:@"Background/LabelTitle"] withClass:NSClassFromString(@"UnityAXElementText")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/ButtonClose"] withClass:NSClassFromString(@"SolitaireButtonRoundAXElement")],
                             [UnityAccessibilityNode node:[self.transform find:@"Background/LabelEmpty"] withClass:NSClassFromString(@"UnityAXElementText")]
        ];
        return [elements _axModaledSorted];
    }
    return nil;
}

- (BOOL)accessibilityViewIsModal
{
    return [self.gameObject.name containsString:@"Popup"];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
