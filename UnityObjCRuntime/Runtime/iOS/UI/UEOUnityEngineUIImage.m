//
//  UEOUnityEngineUIImage.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UEOUnityEngineUIImage.h"
#import "UEOUnityEngineObject.h"

@implementation UEOUnityEngineUIImage


- (float)fillAmount;
{
    return [self safeCSharpFloatForKey:@"fillAmount"];
}

- (void)setFillAmount:(float)fillAmount
{
    return [self safeSetCSharpFloatForKey:@"fillAmount" value:fillAmount];
}

@end
