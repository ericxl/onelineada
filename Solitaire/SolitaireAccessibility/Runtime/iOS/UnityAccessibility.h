//
//  UnityAccessibility.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnityAXElement : NSObject

+ (instancetype)node:(UCObject *)component withClass:(Class)axClass;

@property (nonatomic, strong, readonly, nullable) UCTransform *transform;
@property (nonatomic, strong, readonly, nullable) UCGameObject *gameObject;

@end

@interface NSArray (UnityAccessibilityAdditions)
- (nullable NSArray *)_axModaledSorted;
@end

NS_ASSUME_NONNULL_END
