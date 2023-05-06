//
//  UCUIImage.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUIGraphic.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCUIImage : UCUIGraphic

@property (nonatomic, assign) float fillAmount;
@property (nonatomic, assign) simd_float4 color;

@end

NS_ASSUME_NONNULL_END
