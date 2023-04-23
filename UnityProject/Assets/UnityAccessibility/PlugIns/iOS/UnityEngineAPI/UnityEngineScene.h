#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN

@class UnityEngineComponent;

@interface UnityEngineScene: UnityEngineObject
+ (instancetype)current;
- (NSArray<UnityEngineComponent *> *)findObjectsGetInstanceIDsOfTypeGameObject;
@end


NS_ASSUME_NONNULL_END
