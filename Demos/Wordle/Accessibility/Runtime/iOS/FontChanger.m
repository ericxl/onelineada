//
//  FontChanger.m
//  iOSUnityAccessibilityPlugin
//
//  Created by Eric Liang on 5/4/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnityAXUtils.h"

@interface _WordleFontChanger: NSObject
@end

@implementation _WordleFontChanger

_WordleFontChanger *_gSharedWordleFontChanger = nil;

+ (void)load
{
    _gSharedWordleFontChanger = _WordleFontChanger.new;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:_gSharedWordleFontChanger selector:@selector(_accessibilityStatusChangedCallback:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [center addObserver:_gSharedWordleFontChanger selector:@selector(_accessibilityStatusChangedCallback:) name:UIAccessibilityBoldTextStatusDidChangeNotification object:nil];
    (void)UIAccessibilityButtonShapesEnabled();
    [center addObserver:_gSharedWordleFontChanger selector:@selector(_accessibilityStatusChangedCallback:) name:UIAccessibilityButtonShapesEnabledStatusDidChangeNotification object:nil];
}

static float _UnityAX_UIAccessibilityPreferredContentSizeMultiplier(void)
{
    if ( @available(iOS 10.0, tvOS 10.0, *) )
    {
        UITraitCollection *defaultTraitCollection = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge];
        UITraitCollection *newTraitCollection = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIApplication.sharedApplication.preferredContentSizeCategory];

        UIFont *defaultFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:defaultTraitCollection];
        UIFont *newFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:newTraitCollection];

        CGFloat percentage = ((newFont.pointSize / defaultFont.pointSize) * 100);

        int roundedPercentage = (int)percentage;
        roundedPercentage = roundedPercentage - (roundedPercentage % 5); // bucketize by 5s
        if ( roundedPercentage == 100 ) // avoid rounding error
        {
            return 1;
        }
        return (float)roundedPercentage / (float)100;
    }
    return 1;
}

- (void)_accessibilityStatusChangedCallback:(NSNotification *)notification {
    if ( [notification.name isEqualToString:UIContentSizeCategoryDidChangeNotification] )
    {
        float multiplier = _UnityAX_UIAccessibilityPreferredContentSizeMultiplier();
        float size = 42.0f * multiplier;
        for (UCObject *obj in [[UCGameObject find:@"/Canvas/Keyboard"].transform getComponentsInChildren:@"TMPro.TextMeshProUGUI"]) {
            if ( [obj isKindOfClass:UCTMProTextUGUI.class] )
            {
                [(UCTMProTextUGUI *)obj setFontSize:size];
            }
        }
    }
    else if ( [notification.name isEqualToString:UIAccessibilityButtonShapesEnabledStatusDidChangeNotification] )
    {
        BOOL shapesEnabled = UIAccessibilityButtonShapesEnabled();
        for (UCObject *obj in [[UCGameObject find:@"/Canvas/Keyboard"].transform getComponentsInChildren:@"KeyboardKey"]) {
            if ( shapesEnabled && [(UCComponent *)obj getComponent:@"UnityEngine.UI.Outline"] == nil )
            {
                UCUIOutline *outline = SAFE_CAST_CLASS(UCUIOutline, [[(UCComponent *)obj gameObject] addComponent:@"UnityEngine.UI.Outline"]);
                [outline setEffectDistance:simd_make_float2(8, -8)];
            }
            else if ( !shapesEnabled && [(UCComponent *)obj getComponent:@"UnityEngine.UI.Outline"] != nil )
            {
                // TODO:
            }
        }
    }
    else if ( [notification.name isEqualToString:UIAccessibilityBoldTextStatusDidChangeNotification] )
    {
        BOOL isBold = UIAccessibilityIsBoldTextEnabled();
        for (UCObject *obj in [[UCGameObject find:@"/Canvas/Keyboard"].transform getComponentsInChildren:@"TMPro.TextMeshProUGUI"]) {
            if ( [obj isKindOfClass:UCTMProTextUGUI.class] )
            {
                [(UCTMProTextUGUI *)obj setFontStyle:isBold ? UCUITMProFontStylesBold : UCUITMProFontStylesNormal];
            }
        }
    }
}

@end
