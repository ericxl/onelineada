//
//  UCUIGraphic.m
//  UnityObjC
//
//  Created by Eric Liang on 4/30/23.
//

#import "UCUIGraphic.h"
#import "UCUtilities.h"

@implementation UCUIGraphic

- (UCCanvas *)canvas
{
    return SAFE_CAST_CLASS(UCCanvas, [self safeCSharpObjectForKey:@"canvas"]);
}

@end
