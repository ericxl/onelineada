//
//  UEOUnityEngineRenderer.m
//  libUnityObjCRuntime
//
//  Created by Eric Liang on 4/27/23.
//

#import "UEOUnityEngineRenderer.h"

@implementation UEOUnityEngineRenderer

- (int)sortingOrder
{
    return [self safeCSharpIntForKey:@"sortingOrder"];
}

- (void)setSortingOrder:(int)sortingOrder
{
    [self safeSetCSharpIntForKey:@"sortingOrder" value:sortingOrder];
}

@end
