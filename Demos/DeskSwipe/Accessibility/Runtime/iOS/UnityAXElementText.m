//
//  UnityAXElementText.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface UnityAXElementText : UnityAccessibilityNode
@end

@implementation UnityAXElementText

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityValue
{
    id textComponent = [self.gameObject.transform getComponentInChildren:@"UnityEngine.UI.Text"] ?: [self.gameObject.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"];
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
