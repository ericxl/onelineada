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
    return [self safeSetCSharpStringForKey:@"text" value:text];
}

@end
