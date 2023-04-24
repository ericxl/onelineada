//
//  UEOUtilities.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UEOExtensions)
- (nullable NSArray<NSNumber *> *)_ueoToNumberArray;
@end

@interface NSArray<ObjectType> (UEOExtensions)
- (NSArray *)_ueoMapedObjects:(id (^)(ObjectType obj))block;
- (NSArray *)_ueoFlatMapedObjects:(id (^)(ObjectType obj))block;
@end

NS_ASSUME_NONNULL_END
