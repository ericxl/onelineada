//
//  SolitaireInGameLabelAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface SolitaireInGameLabelAXElement : UnityAccessibilityNode
@end

@implementation SolitaireInGameLabelAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}


- (NSString *)accessibilityLabel
{
    return [[[self.transform find:[NSString stringWithFormat:@"Label%@", self.transform.name]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (NSString *)accessibilityValue
{
    return [[[self.transform find:[NSString stringWithFormat:@"Label%@Value", self.transform.name]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
