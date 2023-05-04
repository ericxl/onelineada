//
//  WordleKeyboardAXElement.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 5/4/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXUtils.h"

@interface WordleKeyboardAXElement : UnityAccessibilityNode
@end

@implementation WordleKeyboardAXElement

- (NSArray *)accessibilityElements
{
    NSArray *elements = [[self.transform getComponentsInChildren:@"KeyboardKey"] ucMapedObjectsWithBlock:^id(UCComponent *component) {
        return [UnityAccessibilityNode node:component withClass:NSClassFromString(@"WordleKeyboardKeyAXElement")];
    }];
    return [elements _axModaledSorted];
}

- (CGRect)unitySpaceAccessibilityFrame
{
    return [SAFE_CAST_CLASS(UCRectTransform, self.transform) unityAXFrameInScreenSpace];
}

@end
