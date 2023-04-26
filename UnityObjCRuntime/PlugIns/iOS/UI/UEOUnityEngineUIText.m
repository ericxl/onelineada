//
//  UEOUnityEngineUIText.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UEOUnityEngineUIText.h"
#import "UEOUnityEngineObject.h"

@implementation UEOUnityEngineUIText

- (NSString *)text;
{
    return [self safeCSharpStringForKey:@"text"];
}

- (void)setText:(NSString *)text
{
    return [self safeSetCSharpStringForKey:@"text" value:text];
}

@end
