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
- (nullable NSArray<UnityEngineComponent *> *)getComponents:(NSString *)component;
- (nullable UnityEngineComponent *)getComponentInChildren:(NSString *)component;
- (nullable NSArray<UnityEngineComponent *> *)getComponentsInChildren:(NSString *)component;
@end

NS_ASSUME_NONNULL_END
