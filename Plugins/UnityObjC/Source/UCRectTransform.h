//
//  UCRectTransform.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCTransform.h"

@class UCCamera;

NS_ASSUME_NONNULL_BEGIN

@interface UCRectTransform : UCTransform

@property (nonatomic, strong, readonly) NSArray<NSString *> *getWorldCorners;
+ (simd_float2)rectUtilityWorldToScreenPoint:(nullable UCCamera *)camera worldPoint:(simd_float3)worldPoint;

@end

NS_ASSUME_NONNULL_END
