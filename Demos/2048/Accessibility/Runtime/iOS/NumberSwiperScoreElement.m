//
//  UnityAXElementBarGroup.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface NumberSwiperScoreElement : UnityAccessibilityNode
@end

@implementation NumberSwiperScoreElement

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityLabel
{
    return [[[self.transform find:[self.gameObject.name stringByAppendingString:@"Text"]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (NSString *)accessibilityValue
{
    return [[[self.transform find:[self.gameObject.name stringByAppendingString:@"Value"]] getComponent:@"TMPro.TextMeshProUGUI"] safeCSharpStringForKey:@"text"];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

@end
