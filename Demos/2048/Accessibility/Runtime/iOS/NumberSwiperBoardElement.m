//
//  NumberSwiperBoardElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 4/30/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface NumberSwiperBoardElement : UnityAccessibilityNode
@end

@implementation NumberSwiperBoardElement

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

- (NSArray *)accessibilityElements
{
    UCTransform *transform = self.transform;
    NSArray *elements = [NSArray ucArrayByIgnoringNilElementsWithCount:16,
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(0,3)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(1,3)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(2,3)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(3,3)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(0,2)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(1,2)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(2,2)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(3,2)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(0,1)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(1,1)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(2,1)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(3,1)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(0,0)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(1,0)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(2,0)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")],
                         [UnityAccessibilityNode node:[transform find:@"Nodes/(3,0)"] withClass:NSClassFromString(@"NumberSwiperNodeElement")]
    ];
    return elements;
}

- (NSString *)accessibilityLabel
{
    return @"Grid";
}

- (UIAccessibilityContainerType)accessibilityContainerType
{
    return UIAccessibilityContainerTypeSemanticGroup;
}

@end
