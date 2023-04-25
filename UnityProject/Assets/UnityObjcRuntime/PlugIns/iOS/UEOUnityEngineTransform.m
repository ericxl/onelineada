//
//  UEOUnityEngineTransform.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUnityEngineTransform.h"
#import "UEOBase.h"
#import "UEOBridge.h"

@implementation UEOUnityEngineTransform

- (nullable UEOUnityEngineTransform *)find:(NSString *)childName
{
    int instanceID = UnityEngineTransformFind_CSharpFunc(self.instanceID, FROM_NSSTRING(childName));
    return SAFE_CAST_CLASS(UEOUnityEngineTransform, [UEOUnityEngineTransform objectWithID:instanceID]);
}

@end
