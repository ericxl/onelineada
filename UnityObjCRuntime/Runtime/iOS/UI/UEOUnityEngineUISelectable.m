//
//  UEOUnityEngineUISelectable.m
//  libUnityObjCRuntime
//
//  Created by Eric Liang on 4/27/23.
//

#import "UEOUnityEngineUISelectable.h"

@implementation UEOUnityEngineUISelectable

- (BOOL)interactable
{
    return [self safeCSharpBoolForKey:@"interactable"];
}

- (void)setInteractable:(BOOL)interactable
{
    [self safeSetCSharpBoolForKey:@"interactable" value:interactable];
}
@end
