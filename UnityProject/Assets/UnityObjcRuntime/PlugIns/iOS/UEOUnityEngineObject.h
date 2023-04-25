#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <simd/types.h>
#import <simd/vector_make.h>

NS_ASSUME_NONNULL_BEGIN

@interface UEOUnityEngineObject: NSObject

+ (nullable instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)objectWithID:(int)instanceID;

@property (nonatomic, assign, readonly) int instanceID;
@property (nonatomic, strong, readonly) NSString *typeFullName;

- (BOOL)safeCSharpBoolForKey:(NSString *)key;
- (int)safeCSharpIntForKey:(NSString *)key;
- (simd_float3)safeCSharpVector3ForKey:(NSString *)key;
- (nullable NSString *)safeCSharpStringForKey:(NSString *)key;
- (nullable UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key;
+ (BOOL)safeCSharpBoolForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (int)safeCSharpIntForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (simd_float3)safeCSharpVector3ForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable NSString *)safeCSharpStringForKey:(NSString *)key forType:(NSString *)cSharpType;
+ (nullable UEOUnityEngineObject *)safeCSharpObjectForKey:(NSString *)key forType:(NSString *)cSharpType;

- (void)safeSetCSharpStringForKey:(NSString *)key value:(nullable NSString *)string;

+ (nullable NSArray<UEOUnityEngineObject *> *)findObjectsOfType:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
