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

+ (nullable instancetype)nodeFrom:(UEOUnityObjCRuntimeBehaviour *)component;
@property (nonatomic, strong, readonly, nullable) UEOUnityObjCRuntimeBehaviour *component;
@property (nonatomic, strong, readonly, nullable) UEOUnityEngineGameObject *gameObject;

@end

@interface UEOUnityObjCRuntimeBehaviour(AccessibilityExtension)
@property (nonatomic, assign) BOOL createAXElement;
@property (nonatomic, strong, setter=setAXClassName:) NSString *axClassName;
- (void)accessibleWithClass:(nullable Class)cls;
@end

NS_ASSUME_NONNULL_END
