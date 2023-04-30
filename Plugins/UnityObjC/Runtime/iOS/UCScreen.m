//
//  UCScreen.m
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCScreen.h"
#import "UnityObjC.h"

@implementation UCScreen

+ (CGFloat)height
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc("UnityEngine.Screen", "height");
}
+ (CGFloat)width
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc("UnityEngine.Screen", "width");
}

@end
