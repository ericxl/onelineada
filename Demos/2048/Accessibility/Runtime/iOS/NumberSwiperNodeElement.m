//
//  NumberSwiperNodeElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 4/30/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface NumberSwiperNodeElement : UnityAccessibilityNode
@end

@implementation NumberSwiperNodeElement

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSString *)accessibilityLabel
{
    return [self.gameObject name];
}

@end
