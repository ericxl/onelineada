//
//  UCUIOutline.h
//  UnityObjC
//
//  Created by Eric Liang on 5/5/23.
//

#import "UCMonoBehaviour.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCUIOutline : UCMonoBehaviour

@property (nonatomic, assign) simd_float2 effectDistance;
@property (nonatomic, assign) simd_float4 effectColor;

@end

NS_ASSUME_NONNULL_END
