//
//  UCSpriteRenderer.h
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@class UCSprite;

@interface UCSpriteRenderer : UCRenderer

@property (nonatomic, strong, readonly, nullable) UCSprite *sprite;

@end

NS_ASSUME_NONNULL_END
