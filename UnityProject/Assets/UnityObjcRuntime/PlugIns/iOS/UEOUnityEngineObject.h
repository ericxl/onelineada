#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityEngineObject: NSObject

+ (nullable instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)objectWithID:(int)instanceID;

@property (nonatomic, assign, readonly) int instanceID;
@property (nonatomic, strong, readonly) NSString *typeFullName;

- (BOOL)safeCSharpBoolForKey:(NSString *)key;
- (int)safeCSharpIntForKey:(NSString *)key;
- (nullable NSString *)safeCSharpStringForKey:(NSString *)key;
- (nullable UnityEngineObject *)safeCSharpObjectForKey:(NSString *)key;

+ (nullable NSArray<UnityEngineObject *> *)findObjectsOfType:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
