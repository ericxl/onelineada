#import <Foundation/Foundation.h>
#import "UnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnityEngineComponent: UnityEngineObject
+ (instancetype)componentWithID:(int)instanceID;
- (nullable UnityEngineComponent *)getComponent:(NSString *)component;
- (nullable UnityEngineComponent *)addComponent:(NSString *)component;
@end

NS_ASSUME_NONNULL_END
