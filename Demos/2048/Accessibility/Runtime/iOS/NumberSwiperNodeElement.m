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
    NSArray *gridInfo = [[[self.gameObject.name stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] componentsSeparatedByString:@","];
    NSString *gridStr = [NSString stringWithFormat:@"column %@, row %@", [gridInfo objectAtIndex:0], [gridInfo objectAtIndex:1]];
    NSString *numberStr = [self.transform getComponentInChildren:@"Number"].gameObject.name ?: @"empty";
    NSString *justCombined = [self.transform getComponentInChildren:@"Number"] != nil ? ([[self.transform getComponentInChildren:@"Number"] safeCSharpBoolForKey:@"justCombined"] ? @"just combined" : nil): nil;
    NSString *label = [[NSArray ucArrayByIgnoringNilElementsWithCount:3, numberStr, justCombined, gridStr] componentsJoinedByString:@", "];
    return label;
}

- (NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions
{
    return @[
        [UIAccessibilityCustomAction.alloc initWithName:@"move left" actionHandler:^BOOL(UIAccessibilityCustomAction * _Nonnull customAction) {
            UCComponent *boardManager = SAFE_CAST_CLASS(UCComponent, [UCObject findObjectsOfType:@"BoardManager"].firstObject);
            if ( boardManager != nil )
            {
                [boardManager safeCSharpPerformFunctionForKey:@"MoveAllToLeft"];
                return YES;
            }
            return NO;
        }],
        [UIAccessibilityCustomAction.alloc initWithName:@"move right" actionHandler:^BOOL(UIAccessibilityCustomAction * _Nonnull customAction) {
            UCComponent *boardManager = SAFE_CAST_CLASS(UCComponent, [UCObject findObjectsOfType:@"BoardManager"].firstObject);
            if ( boardManager != nil )
            {
                [boardManager safeCSharpPerformFunctionForKey:@"MoveAllToRight"];
                return YES;
            }
            return NO;
        }],
        [UIAccessibilityCustomAction.alloc initWithName:@"move down" actionHandler:^BOOL(UIAccessibilityCustomAction * _Nonnull customAction) {
            UCComponent *boardManager = SAFE_CAST_CLASS(UCComponent, [UCObject findObjectsOfType:@"BoardManager"].firstObject);
            if ( boardManager != nil )
            {
                [boardManager safeCSharpPerformFunctionForKey:@"MoveAllToDown"];
                return YES;
            }
            return NO;
        }],
        [UIAccessibilityCustomAction.alloc initWithName:@"move up" actionHandler:^BOOL(UIAccessibilityCustomAction * _Nonnull customAction) {
            UCComponent *boardManager = SAFE_CAST_CLASS(UCComponent, [UCObject findObjectsOfType:@"BoardManager"].firstObject);
            if ( boardManager != nil )
            {
                [boardManager safeCSharpPerformFunctionForKey:@"MoveAllToUp"];
                return YES;
            }
            return NO;
        }]
    ];
}

@end
