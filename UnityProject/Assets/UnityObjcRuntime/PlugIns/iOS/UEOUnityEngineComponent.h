//
//  UEOUnityEngineComponent.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN
@class UnityEngineGameObject;
@class UnityEngineTransform;

@interface UnityEngineComponent: UnityEngineObject

@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, strong, readonly, nullable) UnityEngineGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UnityEngineTransform *transform;

- (nullable UnityEngineComponent *)getComponent:(NSString *)component;
- (nullable NSArray<UnityEngineComponent *> *)getComponents:(NSString *)component;
- (nullable UnityEngineComponent *)getComponentInChildren:(NSString *)component;
- (nullable NSArray<UnityEngineComponent *> *)getComponentsInChildren:(NSString *)component;
- (nullable UnityEngineComponent *)getComponentInParent:(NSString *)component;
- (nullable NSArray<UnityEngineComponent *> *)getComponentsInParent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
