//
//  AppleAccessibilityElementOrdering.h
//  AppleAccessibility
//
//  Copyright © 2021 Apple, Inc. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AppleAccessibilityBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (UnityAccessibilityAdditions)
- (id)_unityAccessibilityModalElement;
- (nullable NSArray *)_unityAccessibilitySorted;
@end

NS_ASSUME_NONNULL_END
