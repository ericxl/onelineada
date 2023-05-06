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
    NSString *state = nil;
    simd_float4 fillColor = SAFE_CAST_CLASS(UCUIImage, [self.transform getComponent:@"UnityEngine.UI.Image"]).color;
    if ( fillColor.x > 0.7 )
    {
        state = @"correct but in wrong spot";
    }
    else if ( fillColor.y > 0.55 )
    {
        state = @"correct spot";
    }
    else if ( fillColor.x > 0.22 && fillColor.y > 0.22 && fillColor.z > 0.22 )
    {
        state = @"incorrect";
    }

    return currentValue.length > 0 ? [[NSArray ucArrayByIgnoringNilElementsWithCount:2, currentValue, state] componentsJoinedByString:@", "] : @"empty";
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
