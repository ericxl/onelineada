//
//  UCComponent.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UCObject.h"

@class UCGameObject;
@class UCTransform;

NS_ASSUME_NONNULL_BEGIN

@interface UCComponent: UCObject

@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, strong, readonly, nullable) UCGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UCTransform *transform;

- (nullable UCComponent *)getComponent:(NSString *)component;
- (nullable NSArray<UCComponent *> *)getComponents:(NSString *)component;
- (nullable UCComponent *)getComponentInChildren:(NSString *)component;
- (nullable NSArray<UCComponent *> *)getComponentsInChildren:(NSString *)component;
- (nullable UCComponent *)getComponentInParent:(NSString *)component;
- (nullable NSArray<UCComponent *> *)getComponentsInParent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
