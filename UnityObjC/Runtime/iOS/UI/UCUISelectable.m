//
//  UCUISelectable.m
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCUISelectable.h"

@implementation UCUISelectable

- (BOOL)interactable
{
    return [self safeCSharpBoolForKey:@"interactable"];
}

- (void)setInteractable:(BOOL)interactable
{
    [self safeSetCSharpBoolForKey:@"interactable" value:interactable];
}
@end
