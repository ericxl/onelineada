//
//  UEOUnityEngineScreen.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/25/23.
//

#import "UEOUnityEngineScreen.h"
#import "UnityEngineObjC.h"

@implementation UEOUnityEngineScreen

+ (CGFloat)height
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc("UnityEngine.Screen", "height");
}
+ (CGFloat)width
{
    return UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc("UnityEngine.Screen", "width");
}

@end
