//
//  CGRect+UnityAXUtils.h
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern CGPoint UCCGRectGetCenter(CGRect rect);

#define __UCRectForRectsSentinel CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX)
#define UCRectForRects(firstRect, ...) _UCRectForRects(firstRect, ##__VA_ARGS__, __UCRectForRectsSentinel)
extern CGRect _UCRectForRects(CGRect firstArgument, ...);
extern CGRect UCUnionRects(NSArray<NSValue *> *rects);

NS_ASSUME_NONNULL_END
