#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UEOUnityEngineObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineScene: NSObject
+ (BOOL)activeSceneIsLoaded;
+ (nullable NSString *)activeSceneName;
@end


NS_ASSUME_NONNULL_END
