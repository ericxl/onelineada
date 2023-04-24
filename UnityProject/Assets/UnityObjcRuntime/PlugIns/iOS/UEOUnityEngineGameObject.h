//
//  UnityEngineGameObject.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN
@class UnityEngineComponent;

@interface UnityEngineGameObject : UnityEngineObject

+ (nullable instancetype)find:(NSString *)name;

- (nullable UnityEngineComponent *)addComponent:(NSString *)component;
- (nullable UnityEngineComponent *)getComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
