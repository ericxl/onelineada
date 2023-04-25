//
//  UnityAccessibilityNode.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityAccessibilityNodeComponent : UEOUnityEngineComponent

@property (nonatomic, strong, nullable) NSString *className;

@end

@interface UnityAXElement : NSObject

+ (nullable instancetype)nodeFrom:(UEOUnityAccessibilityNodeComponent *)component;
@property (nonatomic, strong, readonly, nullable) UEOUnityAccessibilityNodeComponent *component;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineGameObject *gameObject;

@end

NS_ASSUME_NONNULL_END
