//
//  SolitaireCanvasGroupAXElement.m
//  SolitaireAccessibility
//
//  Created by Eric Liang on 4/26/23.
//

#import <Foundation/Foundation.h>
#import "UnityAccessibility.h"

@interface SolitaireCanvasGroupAXElement : UnityAXElement
@end

@implementation SolitaireCanvasGroupAXElement

- (NSArray *)accessibilityElements
{
    if ( !SAFE_CAST_CLASS(UEOUnityEngineCanvas, [self.gameObject getComponent:@"UnityEngine.Canvas"]).enabled  )
    {
        return nil;
    }
    NSLog(@"XL: canvas enabled %@", self.debugDescription);
    return nil;
}

@end
