//
//  UEOUnityEngineBehaviour.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import "UEOUnityEngineBehaviour.h"

@implementation UEOUnityEngineBehaviour

- (BOOL)enabled
{
    return [self safeCSharpBoolForKey:@"enabled"];
}

- (void)setEnabled:(BOOL)enabled
{
    [self safeSetCSharpBoolForKey:@"enabled" value:enabled];
}

@end
