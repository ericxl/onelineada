//
//  UCTMProTextUGUI.m
//  UnityObjC
//
//  Created by Eric Liang on 5/4/23.
//

#import "UCTMProTextUGUI.h"

#import "UCObject.h"

@implementation UCTMProTextUGUI

- (NSString *)text;
{
    return [self safeCSharpStringForKey:@"text"];
}

- (void)setText:(NSString *)text
{
    return [self safeSetCSharpStringForKey:@"text" value:text];
}

- (float)fontSize
{
    return [self safeCSharpFloatForKey:@"fontSize"];
}

- (void)setFontSize:(float)fontSize
{
    return [self safeSetCSharpFloatForKey:@"fontSize" value:fontSize];
}

- (UCUITMProFontStyles)fontStyle
{
    return (UCUITMProFontStyles)[self safeCSharpIntForKey:@"fontStyle"];
}

- (void)setFontStyle:(UCUITMProFontStyles)fontStyle
{
    return [self safeSetCSharpIntForKey:@"fontStyle" value:(int)fontStyle];
}

@end
