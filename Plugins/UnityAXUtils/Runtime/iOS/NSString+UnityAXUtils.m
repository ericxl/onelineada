//
//  NSString+UnityAXUtils.m
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import "NSString+UnityAXUtils.h"
#import <dlfcn.h>

@implementation NSString (UEOExtensions)

- (NSString *)ucDropFirst:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring];
    if ( range.location != NSNotFound && range.location == 0 )
    {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    else
    {
        return self;
    }
}

- (NSString *)ucDropLast:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring options:NSBackwardsSearch];
    if ( range.location != NSNotFound && range.location + range.length == self.length )
    {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    else
    {
        return self;
    }
}

@end

NSString *UCFormatFloatWithPercentage(float value)
{
    NSString *(*format)(float, NSInteger) = dlsym(dlopen("/System/Library/PrivateFrameworks/AXCoreUtilities.framework/AXCoreUtilities", RTLD_NOW), "AXFormatFloatWithPercentage");
    return format(value, 0);
}
