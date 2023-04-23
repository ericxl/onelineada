//
//  AppleAccessibilityRuntime.m
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppleAccessibilityBase.h"
#import "AppleAccessibilityRuntime.h"
#import "AppleAccessibilityElementOrdering.h"
#import "AppleAccessibilityElement.h"

@interface NSObject (UnityAccessibilityPrivate)
- (id)unityView;
@end

APPLE_ACCESSIBILITY_HIDDEN
@interface AppleAccessibilityElementData : NSObject
@property (nonatomic, copy) NSNumber *identifier;
@property (nonatomic, copy) NSNumber *parentIdentifier;
@end

@implementation AppleAccessibilityElementData
@end

@implementation AppleAccessibilityRuntime
{
    NSMutableArray<AccessibilityElementIndexPair *> *_elements;
    NSMutableDictionary<NSNumber *, AccessibilityElementIndexPair *> *_identifierToElement;
}

+ (instancetype)sharedInstance
{
    static AppleAccessibilityRuntime *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[AppleAccessibilityRuntime alloc] init];
    });
    return __sharedInstance;
}

- (NSMutableArray<AccessibilityElementIndexPair *> *)elements
{
    return _elements;
}

- (NSMutableDictionary<NSNumber *, AccessibilityElementIndexPair *> *)identifierToElement
{
    return _identifierToElement;
}

- (instancetype)init
{
    self = [super init];
    _elements = [NSMutableArray array];
    _identifierToElement = [NSMutableDictionary dictionary];
    return self;
}

- (AccessibilityElementIndexPair *)_accessibilityElementIndexPairForIdentifier:(NSNumber *)identifier
{
    AppleAccessibilityElement *element = [[AppleAccessibilityElement alloc] init];
    element.identifier = identifier;

    AccessibilityElementIndexPair *pair = [[AccessibilityElementIndexPair alloc] init];
    pair.element = element;
    pair.identifier = identifier;
    return pair;
}

- (void)registerAccessibilityElementWithIdentifier:(NSNumber *)identifier parent:(NSNumber *)parentIdentifier hasParent:(BOOL)hasParent
{
    AccessibilityElementIndexPair *pair = [_identifierToElement objectForKey:identifier];
    if ( pair == nil )
    {
        pair = [self _accessibilityElementIndexPairForIdentifier:identifier];
        [_identifierToElement setObject:pair forKey:identifier];
        [_elements addObject:pair];
    }

    AccessibilityElementIndexPair *parentPair = hasParent ? [_identifierToElement objectForKey:parentIdentifier] : nil;
    if ( hasParent && parentPair == nil )
    {
        parentPair = [self _accessibilityElementIndexPairForIdentifier:parentIdentifier];
        [_identifierToElement setObject:parentPair forKey:parentIdentifier];
        [_elements addObject:parentPair];
    }

    if ( hasParent )
    {
        pair.parentIdentifier = parentIdentifier;
        pair.element.parent = parentIdentifier;
    }
}

- (void)unregisterAccessibilityElementWithIdentifier:(NSNumber *)identifier
{
    AccessibilityElementIndexPair *element = _identifierToElement[identifier];
    if ( element != nil )
    {
        [_elements removeObject:element];
    }
    [_identifierToElement removeObjectForKey:identifier];
}

- (id)topLevelUnityView
{
    id appController = [[UIApplication sharedApplication] delegate];
    if ( [appController isKindOfClass:NSClassFromString(@"UnityAppController")] && [appController respondsToSelector:@selector(unityView)] )
    {
        return [appController unityView];
    }
    return nil;
}

- (BOOL)isAccessibilityEnabledForUnityView:(id)unityView
{
    return _elements.count > 0;
}

- (NSArray *)accessibilityChildrenForUnityView:(id)unityView
{
    NSMutableArray *elements = [NSMutableArray array];
    for ( AccessibilityElementIndexPair *pair in _elements )
    {
        if ( pair.element.parent == nil )
        {
            [elements addObject:pair.element];
        }
    }
    id modal = [elements _unityAccessibilityModalElement];
    if ( modal != nil )
    {
        return @[modal];
    }
    else
    {
        return [elements _unityAccessibilitySorted];
    }
}

@end
