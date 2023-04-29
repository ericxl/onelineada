//
//  UCUIToggle.m
//  UnityObjC
//
//  Created by Eric Liang on 4/26/23.
//

#import "UCUIToggle.h"

@implementation UCUIToggle

- (BOOL)isOn
{
    return [self safeCSharpBoolForKey:@"isOn"];
}

- (void)setIsOn:(BOOL)isOn
{
    [self safeSetCSharpBoolForKey:@"isOn" value:isOn];
}

@end
