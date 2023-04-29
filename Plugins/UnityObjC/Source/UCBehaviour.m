//
//  UCBehaviour.m
//  UnityObjC
//
//  Created by Eric Liang on 4/26/23.
//

#import "UCBehaviour.h"

@implementation UCBehaviour

- (BOOL)enabled
{
    return [self safeCSharpBoolForKey:@"enabled"];
}

- (void)setEnabled:(BOOL)enabled
{
    [self safeSetCSharpBoolForKey:@"enabled" value:enabled];
}

@end
