//
//  UEOUnityEngineUIToggle.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import "UEOUnityEngineUIToggle.h"

@implementation UEOUnityEngineUIToggle

- (BOOL)isOn
{
    return [self safeCSharpBoolForKey:@"isOn"];
}

- (void)setIsOn:(BOOL)isOn
{
    [self safeSetCSharpBoolForKey:@"isOn" value:isOn];
}

@end
