//
//  UEOUnityEngineComponent.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnityEngineComponent: UnityEngineObject
- (nullable UnityEngineComponent *)getComponent:(NSString *)component;
@end

NS_ASSUME_NONNULL_END
