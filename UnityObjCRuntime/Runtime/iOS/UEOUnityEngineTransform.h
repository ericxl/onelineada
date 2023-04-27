//
//  UEOUnityEngineTransform.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineTransform : UEOUnityEngineComponent

- (nullable UEOUnityEngineTransform *)find:(NSString *)childName;
@property (nonatomic, assign) simd_float3 position;
@property (nonatomic, assign) simd_float3 localScale;
@end

NS_ASSUME_NONNULL_END
