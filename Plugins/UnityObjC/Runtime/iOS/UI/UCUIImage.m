//
//  UCUIImage.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUIImage.h"
#import "UCObject.h"

@implementation UCUIImage


- (float)fillAmount;
{
    return [self safeCSharpFloatForKey:@"fillAmount"];
}

- (void)setFillAmount:(float)fillAmount
{
    return [self safeSetCSharpFloatForKey:@"fillAmount" value:fillAmount];
}

@end
