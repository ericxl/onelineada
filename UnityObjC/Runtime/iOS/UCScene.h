//
//  UCScene.h
//  UnityObjC
//
//  Created by Eric Liang on 4/27/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UCObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCScene: NSObject
+ (BOOL)activeSceneIsLoaded;
+ (nullable NSString *)activeSceneName;
@end


NS_ASSUME_NONNULL_END
