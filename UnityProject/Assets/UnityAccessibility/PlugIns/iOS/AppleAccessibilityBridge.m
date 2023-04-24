//
//  AppleAccessibilityBridge.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppleAccessibilityBase.h"
#import <TargetConditionals.h>
#import "AppleAccessibilitySafeOverride.h"
#import "AppleAccessibilityRuntime.h"

#pragma mark Notifictions

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostFeatureEnabledNotification(const char *name, const bool value)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name == NULL ? nil : [NSString stringWithUTF8String:name] object:@(value)];
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostScreenChangedNotification(void)
{
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostLayoutChangedNotification(void)
{
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostAnnouncementNotification(const char *announcement)
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement == NULL ? nil : [NSString stringWithUTF8String:announcement]);
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostPageScrolledNotification(const char *position)
{
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, position == NULL ? nil : [NSString stringWithUTF8String:position]);
}

#pragma mark Elements

typedef char *(* AccessibilityFrameDelegate)(int32_t);
static AccessibilityFrameDelegate __axFrameDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityFrame(AccessibilityFrameDelegate delegate) { __axFrameDelegate = delegate; }

typedef char *(* AccessibilityLabelDelegate)(int32_t);
static AccessibilityLabelDelegate __axLabelDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityLabel(AccessibilityLabelDelegate delegate) { __axLabelDelegate = delegate; }

typedef uint64_t (* AccessibilityTraitsDelegate)(int32_t);
static AccessibilityTraitsDelegate __axTraitsDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityTraits(AccessibilityTraitsDelegate delegate) { __axTraitsDelegate = delegate; }

typedef bool (* AccessibilityIsElementDelegate)(int32_t);
static AccessibilityIsElementDelegate __axIsElementDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityIsElement(AccessibilityIsElementDelegate delegate) { __axIsElementDelegate = delegate; }

typedef char *(* AccessibilityHintDelegate)(int32_t);
static AccessibilityHintDelegate __axHintDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityHint(AccessibilityHintDelegate delegate) { __axHintDelegate = delegate; }

typedef char *(* AccessibilityValueDelegate)(int32_t);
static AccessibilityValueDelegate __axValueDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityValue(AccessibilityValueDelegate delegate) { __axValueDelegate = delegate; }

typedef char *(* AccessibilityIdentifierDelegate)(int32_t);
static AccessibilityIdentifierDelegate __axIdentifierDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityIdentifier(AccessibilityIdentifierDelegate delegate) { __axIdentifierDelegate = delegate; }

typedef bool (* AccessibilityViewIsModalDelegate)(int32_t);
static AccessibilityViewIsModalDelegate __axViewIsModalDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityViewIsModal(AccessibilityViewIsModalDelegate delegate) { __axViewIsModalDelegate = delegate; }

typedef char *(* AccessibilityActivationPointDelegate)(int32_t);
static AccessibilityActivationPointDelegate __axActivationPointDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityActivationPoint(AccessibilityActivationPointDelegate delegate) { __axActivationPointDelegate = delegate; }

typedef uint64_t (* AccessibilityCustomActionsCountDelegate)(int32_t);
static AccessibilityCustomActionsCountDelegate __axCustomActionsCountDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityCustomActionsCount(AccessibilityCustomActionsCountDelegate delegate) { __axCustomActionsCountDelegate = delegate; }

typedef bool (* AccessibilityPerformCustomActionDelegate)(int32_t, int32_t);
static AccessibilityPerformCustomActionDelegate __axPerformCustomActionDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityPerformCustomAction(AccessibilityPerformCustomActionDelegate delegate) { __axPerformCustomActionDelegate = delegate; }

typedef char *(* AccessibilityCustomActionNameDelegate)(int32_t, int32_t);
static AccessibilityCustomActionNameDelegate __axCustomActionNameDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityCustomActionName(AccessibilityCustomActionNameDelegate delegate) { __axCustomActionNameDelegate = delegate; }

typedef bool (* AccessibilityScrollDelegate)(int32_t, uint32_t);
static AccessibilityScrollDelegate __axScrollDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityScroll(AccessibilityScrollDelegate delegate) { __axScrollDelegate = delegate; }

typedef bool (* AccessibilityPerformMagicTapDelegate)(int32_t);
static AccessibilityPerformMagicTapDelegate __axPerformMagicTapDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityPerformMagicTap(AccessibilityPerformMagicTapDelegate delegate) { __axPerformMagicTapDelegate = delegate; }

typedef bool (* AccessibilityPerformEscapeDelegate)(int32_t);
static AccessibilityPerformEscapeDelegate __axPerformEscapeDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityPerformEscape(AccessibilityPerformEscapeDelegate delegate) { __axPerformEscapeDelegate = delegate; }

typedef bool (* AccessibilityActivateDelegate)(int32_t);
static AccessibilityActivateDelegate __axActivateDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityActivate(AccessibilityActivateDelegate delegate) { __axActivateDelegate = delegate; }

typedef void (* AccessibilityIncrementDelegate)(int32_t);
static AccessibilityIncrementDelegate __axIncrementDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityIncrement(AccessibilityIncrementDelegate delegate) { __axIncrementDelegate = delegate; }

typedef void (* AccessibilityDecrementDelegate)(int32_t);
static AccessibilityDecrementDelegate __axDecrementDelegate = NULL;
APPLE_ACCESSIBILITY_EXTERN void _UnityAX_registerAccessibilityDecrement(AccessibilityDecrementDelegate delegate) { __axDecrementDelegate = delegate; }

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_InitializeAXRuntime(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AppleAccessibilitySafeOverrideInstall(@"UnityViewAccessibility");

        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityFrame:^CGRect(NSNumber *identifier) {
            if ( __axFrameDelegate == NULL )
            {
                return CGRectZero;
            }
            char *rectStr = __axFrameDelegate((int32_t)identifier.integerValue);
            return rectStr == NULL ? CGRectZero : CGRectFromString([NSString stringWithUTF8String:rectStr]);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityLabel:^NSString *(NSNumber *identifier) {
            if ( __axLabelDelegate == NULL )
            {
                return nil;
            }
            char *str = __axLabelDelegate((int32_t)identifier.integerValue);
            return str == NULL ? nil : [NSString stringWithUTF8String:str];
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityTraits:^UIAccessibilityTraits(NSNumber *identifier) {
            if ( __axTraitsDelegate == NULL )
            {
                return (uint64_t)0;
            }
            return __axTraitsDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityCustomActionsCount:^uint64_t(NSNumber *identifier) {
            if ( __axCustomActionsCountDelegate == NULL )
            {
                return (uint64_t)0;
            }
            return __axCustomActionsCountDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityPerformCustomAction:^BOOL(NSNumber *identifier, NSNumber *idx) {
            if ( __axPerformCustomActionDelegate == NULL )
            {
                return NO;
            }
            return __axPerformCustomActionDelegate((int32_t)identifier.integerValue, (int32_t)idx.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityCustomActionName:^NSString *(NSNumber *identifier, NSNumber *idx) {
            if ( __axCustomActionNameDelegate == NULL )
            {
                return nil;
            }
            char *str = __axCustomActionNameDelegate((int32_t)identifier.integerValue, (int32_t)idx.integerValue);
            return str == NULL ? nil : [NSString stringWithUTF8String:str];
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityIsAccessibilityElement:^BOOL(NSNumber *identifier) {
            if ( __axIsElementDelegate == NULL )
            {
                return YES;
            }
            return __axIsElementDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityHint:^NSString *(NSNumber *identifier) {
            if ( __axHintDelegate == NULL )
            {
                return nil;
            }
            char *str = __axHintDelegate((int32_t)identifier.integerValue);
            return str == NULL ? nil : [NSString stringWithUTF8String:str];
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityValue:^NSString *(NSNumber *identifier) {
            if ( __axValueDelegate == NULL )
            {
                return nil;
            }
            char *str = __axValueDelegate((int32_t)identifier.integerValue);
            return str == NULL ? nil : [NSString stringWithUTF8String:str];
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityActivationPoint:^CGPoint(NSNumber *identifier) {
            if ( __axActivationPointDelegate == NULL )
            {
                return kAXCenterPointDefaultPoint;
            }
            char *pointStr = __axActivationPointDelegate((int32_t)identifier.integerValue);
            return pointStr == NULL ? kAXCenterPointDefaultPoint : CGPointFromString([NSString stringWithUTF8String:pointStr]);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityIdentifier:^NSString *(NSNumber *identifier) {
            if ( __axIdentifierDelegate == NULL )
            {
                return nil;
            }
            char *str = __axIdentifierDelegate((int32_t)identifier.integerValue);
            return str == NULL ? nil : [NSString stringWithUTF8String:str];
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityViewIsModal:^BOOL(NSNumber *identifier) {
            if ( __axViewIsModalDelegate == NULL )
            {
                return NO;
            }
            return __axViewIsModalDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityScroll:^BOOL(NSNumber *identifier, UIAccessibilityScrollDirection direction) {
            if ( __axScrollDelegate == NULL )
            {
                return NO;
            }
            return __axScrollDelegate((int32_t)identifier.integerValue, (int32_t)direction);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityPerformMagicTap:^BOOL(NSNumber *identifier) {
            if ( __axPerformMagicTapDelegate == NULL )
            {
                return NO;
            }
            return __axPerformMagicTapDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityPerformEscape:^BOOL(NSNumber *identifier) {
            if ( __axPerformEscapeDelegate == NULL )
            {
                return NO;
            }
            return __axPerformEscapeDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityActivate:^BOOL(NSNumber *identifier) {
            if ( __axActivateDelegate == NULL )
            {
                return NO;
            }
            return __axActivateDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityIncrement:^void(NSNumber *identifier) {
            if ( __axIncrementDelegate == NULL )
            {
                return;
            }
            __axIncrementDelegate((int32_t)identifier.integerValue);
        }];
        [AppleAccessibilityRuntime.sharedInstance setUnityAccessibilityDecrement:^void(NSNumber *identifier) {
            if ( __axDecrementDelegate == NULL )
            {
                return;
            }
            __axDecrementDelegate((int32_t)identifier.integerValue);
        }];
    });
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_PostUnityViewChanged(void)
{
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_RegisterElementWithIdentifier(int32_t identifier, int32_t parentIdentifier, bool hasParent)
{
    [AppleAccessibilityRuntime.sharedInstance registerAccessibilityElementWithIdentifier:@(identifier) parent: hasParent ? @(parentIdentifier) : nil hasParent:hasParent];
}

APPLE_ACCESSIBILITY_EXTERN void _UnityAX_UnregisterElementWithIdentifier(int32_t identifier)
{
    [AppleAccessibilityRuntime.sharedInstance unregisterAccessibilityElementWithIdentifier:@(identifier)];
}
