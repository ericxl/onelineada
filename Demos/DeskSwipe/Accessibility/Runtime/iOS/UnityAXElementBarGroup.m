//
//  UnityAXElementBarGroup.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface UnityAXElementBarGroup : UnityAccessibilityNode
@end

@implementation UnityAXElementBarGroup

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityLabel
{
    return [self.gameObject.name ucDropLast:@" Bar Group"];
}

- (NSString *)accessibilityValue
{
    id image = [self.gameObject.transform find:[self.gameObject.name ucDropLast:@" Group"]];
    UCUIImage *imageComponent = SAFE_CAST_CLASS(UCUIImage, [image getComponent:@"UnityEngine.UI.Image"]);
    return UCFormatFloatWithPercentage(imageComponent.fillAmount);
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

@end
