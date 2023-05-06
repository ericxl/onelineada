//
//  CGRect+UnityAXUtils.m
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import "CGRect+UnityAXUtils.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UnityObjC.h"

CGPoint UCCGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static CGRect _UEOFrameForRectsWithVariadics(CGRect firstArgument, va_list arguments)
{
    CGRect result = CGRectNull;
    if ( !CGRectIsEmpty(firstArgument) )
    {
        result = firstArgument;
    }

    BOOL done = NO;
    while ( !done )
    {
        CGRect nextArgument = va_arg(arguments, CGRect);
        if ( !CGRectIsEmpty(nextArgument) )
        {
            done = CGRectEqualToRect(nextArgument, __UCRectForRectsSentinel);
            if ( !done )
            {
                if ( CGRectIsEmpty(result) )
                {
                    result = nextArgument;
                }
                else
                {
                    result = CGRectUnion(result, nextArgument);
                }
            }
        }
    }

    return result;
}

CGRect _UCRectForRects(CGRect firstArgument, ...)
{
    va_list args;
    va_start(args, firstArgument);
    CGRect result = _UEOFrameForRectsWithVariadics(firstArgument, args);
    va_end(args);

    return result;
}

CGRect UCUnionRects(NSArray<NSValue *> *rects)
{
    CGRect result = CGRectNull;
    for (NSValue *value in rects)
    {
        CGRect next = [value ucCGRectValue];
        if ( !CGRectIsEmpty(next) )
        {
            if ( CGRectIsEmpty(result) )
            {
                result = next;
            }
            else
            {
                result = CGRectUnion(result, next);
            }
        }
    }
    return result;
}

