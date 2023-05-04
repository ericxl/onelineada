//
//  WordleTileAXElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 5/4/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface WordleTileAXElement : UnityAccessibilityNode
@end

@implementation WordleTileAXElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    NSString *currentValue = [[self.transform getComponentInChildren:@"TMPro.TextMeshProUGUI"]  safeCSharpStringForKey:@"text"];
    return currentValue.length > 0 ? currentValue : @"empty";
}

- (NSString *)accessibilityValue
{
    return @"test tile";
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
