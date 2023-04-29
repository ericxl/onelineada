//
//  UCSpriteRenderer.m
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCSpriteRenderer.h"
#import "UnityObjC.h"

@implementation UCSpriteRenderer

- (UCSprite *)sprite
{
    return SAFE_CAST_CLASS(UCSprite, [self safeCSharpObjectForKey:@"sprite"]);
}

@end

