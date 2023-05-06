//
//  NSArray+UnityAXUtils.h
//  UnityAXUtils
//
//  Created by Eric Liang on 5/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (UEOExtensions)
- (nullable ObjectType)ucSafeObjectAtIndex:(NSUInteger)index;
- (NSArray<ObjectType> *)ucFilterObjectsUsingBlock:(BOOL (NS_NOESCAPE ^)(ObjectType item))filterBlock;
- (nullable ObjectType)ucFirstObjectUsingBlock:(BOOL (NS_NOESCAPE ^)(ObjectType item))predicateBlock;
- (NSArray *)ucMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (NSArray *)ucFlatMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (ObjectType)ucMaxObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (ObjectType)ucMinObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (NSNumber *)ucMaxNumber;
- (NSNumber *)ucMinNumber;
+ (nullable instancetype)ucArrayByIgnoringNilElementsWithCount:(NSUInteger)elementCount, ...;
@end

NS_ASSUME_NONNULL_END
