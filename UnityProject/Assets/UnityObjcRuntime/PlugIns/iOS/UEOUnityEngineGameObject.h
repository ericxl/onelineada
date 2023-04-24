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
@class UnityEngineTransform;
@class UnityEngineScene;

@interface UnityEngineGameObject : UnityEngineObject

@property (nonatomic, assign, readonly) int layer;
@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, assign, readonly) BOOL activeSelf;
@property (nonatomic, assign, readonly) BOOL activeInHierarchy;
@property (nonatomic, strong, readonly, nullable) UnityEngineGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UnityEngineTransform *transform;
@property (nonatomic, strong, readonly, nullable) UnityEngineScene *scene;

+ (nullable instancetype)find:(NSString *)name;

- (nullable UnityEngineComponent *)addComponent:(NSString *)component;
- (nullable UnityEngineComponent *)getComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
