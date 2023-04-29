//
//  UCRenderer.m
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import "UCRenderer.h"

@implementation UCRenderer

- (int)sortingOrder
{
    return [self safeCSharpIntForKey:@"sortingOrder"];
}

- (void)setSortingOrder:(int)sortingOrder
{
    [self safeSetCSharpIntForKey:@"sortingOrder" value:sortingOrder];
}

@end