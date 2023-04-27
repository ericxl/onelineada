//
//  UnityAXElement.h
//  UnityEngineAPI+Accessibility+Plugin
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnityAXElement : NSObject

+ (instancetype)node:(UEOUnityEngineObject *)component withClass:(Class)axClass;

@property (nonatomic, strong, readonly, nullable) UEOUnityEngineGameObject *gameObject;

@end

NS_ASSUME_NONNULL_END
