//
//  UnityEngineGameObject.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UEOUnityEngineObject.h"

@class UEOUnityEngineComponent;
@class UEOUnityEngineTransform;
@class UEOUnityEngineScene;

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineGameObject : UEOUnityEngineObject

@property (nonatomic, assign, readonly) int layer;
@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, assign, readonly) BOOL activeSelf;
@property (nonatomic, assign, readonly) BOOL activeInHierarchy;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineTransform *transform;

+ (nullable instancetype)find:(NSString *)name;

- (nullable UEOUnityEngineComponent *)addComponent:(NSString *)component;
- (nullable UEOUnityEngineComponent *)getComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
