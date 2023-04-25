//
//  UEOUnityEngineComponent.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineObject.h"

@class UEOUnityEngineGameObject;
@class UEOUnityEngineTransform;

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineComponent: UEOUnityEngineObject

@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineTransform *transform;

- (nullable UEOUnityEngineComponent *)getComponent:(NSString *)component;
- (nullable NSArray<UEOUnityEngineComponent *> *)getComponents:(NSString *)component;
- (nullable UEOUnityEngineComponent *)getComponentInChildren:(NSString *)component;
- (nullable NSArray<UEOUnityEngineComponent *> *)getComponentsInChildren:(NSString *)component;
- (nullable UEOUnityEngineComponent *)getComponentInParent:(NSString *)component;
- (nullable NSArray<UEOUnityEngineComponent *> *)getComponentsInParent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
