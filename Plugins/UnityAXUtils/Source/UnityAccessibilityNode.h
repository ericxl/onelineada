//
//  UnityAccessibilityNode.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import <Foundation/Foundation.h>
#import "UnityObjC.h"
NS_ASSUME_NONNULL_BEGIN

@interface UnityAccessibilityNode : NSObject

+ (instancetype)node:(UCObject *)component withClass:(Class)axClass;

@property (nonatomic, strong, readonly, nullable) UCTransform *transform;
@property (nonatomic, strong, readonly, nullable) UCGameObject *gameObject;

- (BOOL)isVisible;
- (CGRect)accessibilityFrame NS_UNAVAILABLE;
- (CGPoint)accessibilityActivationPoint NS_UNAVAILABLE;
- (CGRect)unitySpaceAccessibilityFrame;
- (CGPoint)unitySpaceAccessibilityActivationPoint;

@end

NS_ASSUME_NONNULL_END
