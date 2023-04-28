//
//  UCTransform.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UCComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCTransform : UCComponent

- (nullable UCTransform *)find:(NSString *)childName;
@property (nonatomic, assign) simd_float3 position;
@property (nonatomic, assign) simd_float3 localScale;
@end

NS_ASSUME_NONNULL_END
