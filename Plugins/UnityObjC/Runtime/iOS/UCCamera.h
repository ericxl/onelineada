//
//  UCCamera.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCCamera : UCComponent

@property (nonatomic, strong, class, readonly) UCCamera *main;

- (simd_float3)worldToScreenPoint:(simd_float3)screenPoint;

@end

NS_ASSUME_NONNULL_END
