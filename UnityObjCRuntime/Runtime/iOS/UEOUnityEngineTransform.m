//
//  UEOUnityEngineTransform.m
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import "UEOUnityEngineTransform.h"
#import "UEOUtilities.h"

@implementation UEOUnityEngineTransform

- (nullable UEOUnityEngineTransform *)find:(NSString *)childName
{
    int instanceID = UnityEngineTransformFind_CSharpFunc(self.instanceID, FROM_NSSTRING(childName));
    return SAFE_CAST_CLASS(UEOUnityEngineTransform, [UEOUnityEngineTransform objectWithID:instanceID]);
}

@end
