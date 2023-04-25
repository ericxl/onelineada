//
//  UEOUnityEngineRectTransform.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/24/23.
//

#import "UEOUnityEngineTransform.h"

@class UEOUnityEngineCamera;

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineRectTransform : UEOUnityEngineTransform

@property (nonatomic, strong, readonly) NSArray<NSString *> *getWorldCorners;
+ (simd_float2)rectUtilityWorldToScreenPoint:(nullable UEOUnityEngineCamera *)camera worldPoint:(simd_float3)worldPoint;

@end

NS_ASSUME_NONNULL_END
