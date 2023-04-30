//
//  UnityAXElementProgressDisplay.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface UnityAXElementProgressDisplay : UnityAccessibilityNode
@end

@implementation UnityAXElementProgressDisplay

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityValue
{
    id text = [self.gameObject.transform find:@"Days Survived Text"];
    id textComponent = [text getComponentInChildren:@"UnityEngine.UI.Text"] ?: [text getComponentInChildren:@"TMPro.TextMeshProUGUI"];
    return [textComponent safeCSharpStringForKey:@"text"];
}

- (NSString *)accessibilityLabel
{
    id text = [self.gameObject.transform find:@"Days Survived Label"];
    id textComponent = [text getComponentInChildren:@"UnityEngine.UI.Text"] ?: [text getComponentInChildren:@"TMPro.TextMeshProUGUI"];
    return [textComponent safeCSharpStringForKey:@"text"];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitStaticText;
}

@end
