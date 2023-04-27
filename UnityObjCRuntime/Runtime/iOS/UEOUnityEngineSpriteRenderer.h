//
//  UEOUnityEngineSpriteRenderer.h
//  libUnityObjCRuntime
//
//  Created by Eric Liang on 4/27/23.
//

#import "UEOUnityEngineRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@class UEOUnityEngineSprite;

@interface UEOUnityEngineSpriteRenderer : UEOUnityEngineRenderer

@property (nonatomic, strong, readonly, nullable) UEOUnityEngineSprite *sprite;

@end

NS_ASSUME_NONNULL_END
