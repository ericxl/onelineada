//
//  UCCanvas.m
//  UnityObjC
//
//  Created by Eric Liang on 4/26/23.
//

#import "UCCanvas.h"
#import "UnityObjC.h"

@implementation UCCanvas

- (UCCanvasRenderMode)renderMode
{
    return (UCCanvasRenderMode)[self safeCSharpIntForKey:@"renderMode"];
}

- (UCCamera *)worldCamera
{
    return SAFE_CAST_CLASS(UCCamera, [self safeCSharpObjectForKey:@"worldCamera"]);
}

@end
