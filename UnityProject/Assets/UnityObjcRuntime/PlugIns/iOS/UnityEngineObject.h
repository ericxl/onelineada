#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityEngineObject: NSObject

+ (nullable instancetype)objectWithID:(int)instanceID;
@property (nonatomic, assign, readonly) int instanceID;
@end

NS_ASSUME_NONNULL_END
