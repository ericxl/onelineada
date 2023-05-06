//
//  NSString+UnityAXUtils.h
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UEOExtensions)
- (NSString *)ucDropFirst:(NSString *)substring;
- (NSString *)ucDropLast:(NSString *)substring;
@end

extern NSString *UCFormatFloatWithPercentage(float value);

NS_ASSUME_NONNULL_END
