//
//  UCSprite.m
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCSprite.h"

@implementation UCSprite

- (CGRect)textureRect
{
    return [self safeCSharpRectForKey:@"textureRect"];
}

@end
