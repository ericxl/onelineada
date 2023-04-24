//
//  UnityAccessibilityNode.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnityAccessibilityNodeComponent : UnityEngineComponent

@end

@interface UnityAccessibilityNode : NSObject

+ (nullable instancetype)nodeFrom:(UnityAccessibilityNodeComponent *)component;

@end

NS_ASSUME_NONNULL_END
