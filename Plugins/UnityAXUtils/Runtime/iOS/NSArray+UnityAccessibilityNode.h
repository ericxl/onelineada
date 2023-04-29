//
//  NSArray+UnityAccessibilityNode.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (UnityAccessibilityAdditions)
- (nullable NSArray *)_axModaledSorted;
@end

NS_ASSUME_NONNULL_END
