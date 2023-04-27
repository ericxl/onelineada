//
//  UEOUnityEngineSprite.m
//  libUnityObjCRuntime
//
//  Created by Eric Liang on 4/27/23.
//

#import "UEOUnityEngineSprite.h"

@implementation UEOUnityEngineSprite

- (CGRect)textureRect
{
    return [self safeCSharpRectForKey:@"textureRect"];
}

@end
