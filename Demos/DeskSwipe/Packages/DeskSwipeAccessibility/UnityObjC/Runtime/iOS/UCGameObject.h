//
//  UCGameObject.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import <Foundation/Foundation.h>
#import "UCObject.h"

@class UCComponent;
@class UCTransform;
@class UCScene;

NS_ASSUME_NONNULL_BEGIN

@interface UCGameObject : UCObject

@property (nonatomic, assign, readonly) int layer;
@property (nonatomic, strong, readonly, nullable) NSString *tag;
@property (nonatomic, assign, readonly) BOOL activeSelf;
@property (nonatomic, assign, readonly) BOOL activeInHierarchy;
@property (nonatomic, strong, readonly, nullable) UCGameObject *gameObject;
@property (nonatomic, strong, readonly, nullable) UCTransform *transform;

+ (nullable instancetype)find:(NSString *)name;

- (nullable UCComponent *)addComponent:(NSString *)component;
- (nullable UCComponent *)getComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
