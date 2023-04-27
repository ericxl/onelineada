//
//  UEOUnityEngineCamera.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UEOUnityEngineComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineCamera : UEOUnityEngineComponent

@property (nonatomic, strong, class, readonly) UEOUnityEngineCamera *main;

- (simd_float3)worldToScreenPoint:(simd_float3)screenPoint;

@end

NS_ASSUME_NONNULL_END
