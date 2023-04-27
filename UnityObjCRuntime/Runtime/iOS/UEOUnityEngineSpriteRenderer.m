//
//  UEOUnityEngineSpriteRenderer.m
//  libUnityObjCRuntime
//
//  Created by Eric Liang on 4/27/23.
//

#import "UEOUnityEngineSpriteRenderer.h"
#import "UnityEngineObjC.h"

@implementation UEOUnityEngineSpriteRenderer

- (UEOUnityEngineSprite *)sprite
{
    return SAFE_CAST_CLASS(UEOUnityEngineSprite, [self safeCSharpObjectForKey:@"sprite"]);
}

@end

