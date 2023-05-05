//
//  UCUIText.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUIText.h"
#import "UCObject.h"

@implementation UCUIText

- (NSString *)text;
{
    return [self safeCSharpStringForKey:@"text"];
}

- (void)setText:(NSString *)text
{
    [self safeSetCSharpStringForKey:@"text" value:text];
}

- (int)fontSize
{
    return [self safeCSharpIntForKey:@"fontSize"];
}

- (void)setFontSize:(int)fontSize
{
    [self safeSetCSharpIntForKey:@"fontSize" value:fontSize];
}

- (UCUIFontStyle)fontStyle
{
    return [self safeCSharpIntForKey:@"fontStyle"];
}

- (void)setFontStyle:(UCUIFontStyle)fontStyle
{
    [self safeSetCSharpIntForKey:@"fontStyle" value:(int)fontStyle];
}

@end
