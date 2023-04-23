//
//  UnityEngineGameObject.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN
@class UnityEngineComponent;

@interface UnityEngineGameObject : UnityEngineObject

+ (nullable instancetype)find:(NSString *)name;

- (nullable UnityEngineComponent *)getComponent:(NSString *)component;
- (nullable UnityEngineComponent *)addComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
