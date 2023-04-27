//
//  UEOUtilities.h
//  UnityEngineAPI+Accessibility
//
//  Created by Eric Liang on 4/23/23.
//

#import <Foundation/Foundation.h>
#import "UnityEngineObjC.h"
#import <simd/types.h>
#import <simd/vector_make.h>

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectTypeFullName, const char *, (int));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVoidForKey, void, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKey, BOOL, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKey, float, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKey, double, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKey, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKey, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpBoolForKeyStatic, BOOL, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpIntForKeyStatic, int, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpFloatForKeyStatic, float, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpDoubleForKeyStatic, double, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpVector3ForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpStringForKeyStatic, const char *, (const char *, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeCSharpObjectForKeyStatic, int, (const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpBoolForKey, void, (int, const char *, BOOL));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpFloatForKey, void, (int, const char *, float));
CSHARP_BRIDGE_INTERFACE(UnityEngineObjectSafeSetCSharpStringForKey, void, (int, const char *, const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineObjectFindObjectsOfType, const char *, (const char *));

CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponents, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInChildren, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInChildren, const char *, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentInParent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineComponentGetComponentsInParent, const char *, (int, const char *));

#pragma mark GameObject

CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectFind, int, (const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectAddComponent, int, (int, const char *));
CSHARP_BRIDGE_INTERFACE(UnityEngineGameObjectGetComponent, int, (int, const char *));

#pragma mark Transform

CSHARP_BRIDGE_INTERFACE(UnityEngineTransformFind, int, (int, const char *));

#pragma mark RectTransform
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformGetWorldCorners, const char *, (int));
CSHARP_BRIDGE_INTERFACE(UnityEngineRectTransformUtilityWorldToScreenPoint, const char *, (int, const char *));


NS_ASSUME_NONNULL_BEGIN

@interface NSString (UEOExtensions)
- (nullable NSArray<NSNumber *> *)_ueoToNumberArray;
- (nullable NSArray<NSString *> *)_ueoToStringArray;
- (NSString *)_ueoDropLast:(NSString *)substring;
@end

@interface NSArray<__covariant ObjectType> (UEOExtensions)
- (NSArray<ObjectType> *)_ueoFilterObjectsUsingBlock:(BOOL (NS_NOESCAPE ^)(ObjectType item, NSUInteger index))filterBlock;
- (NSArray *)_ueoMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (NSArray *)_ueoFlatMapedObjectsWithBlock:(id (^)(ObjectType obj))block;
- (ObjectType)_ueoMaxObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (ObjectType)_ueoMinObjectWithBlock:(NSComparisonResult (^)(ObjectType obj1, ObjectType obj2))block;
- (NSNumber *)_ueoMaxNumber;
- (NSNumber *)_ueoMinNumber;
@end

extern NSString *UEOSimdFloat2ToString(simd_float2 vector);
extern simd_float2 UEOSimdFloat2FromString(NSString *str);
extern NSArray<NSNumber *> *UEOSimdFloat2ToArray(simd_float2 vector);
extern simd_float2 UEOSimdFloat2FromArray(NSArray<NSNumber *> *array);

extern NSString *UEOSimdFloat3ToString(simd_float3 vector);
extern simd_float3 UEOSimdFloat3FromString(NSString *str);
extern NSArray<NSNumber *> *UEOSimdFloat3ToArray(simd_float3 vector);
extern simd_float3 UEOSimdFloat3FromArray(NSArray<NSNumber *> *array);

extern NSString *UEOFormatFloatWithPercentage(float value);

#define __UEORectForRectsSentinel CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX)
#define UEORectForRects(firstRect, ...) _UEORectForRects(firstRect, ##__VA_ARGS__, __UEORectForRectsSentinel)
extern CGRect _UEORectForRects(CGRect firstArgument, ...);


#pragma mark Safe Override

extern void _ObjCSafeOverrideInstall(NSString *categoryName);

#define ObjCDefineSafeOverride(quotedTargetClassName, override) \
    ObjCDeclareSafeOverride(override) \
    ObjCDefineDeclaredSafeOverride(quotedTargetClassName, override)

#define ObjCDeclareSafeOverride(override) \
    __attribute__((visibility("hidden"))) \
    @interface __##override##_super : _ObjCSafeOverride \
    @end \
    __attribute__((visibility("hidden"))) \
    @interface override : __##override##_super \
    @end

#define ObjCDefineDeclaredSafeOverride(quotedTargetClassName, override) \
    @implementation __##override##_super \
    @end \
    @implementation override (SafeOverride) \
    + (NSString *)objCSafeOverrideTargetClassName \
    { \
        return quotedTargetClassName; \
    } \
    + (void)_initializeObjCSafeOverride \
    { \
        [self installObjCSafeOverrideOnClassNamed:quotedTargetClassName]; \
    } \
    @end \

@interface _ObjCSafeOverride : NSObject

// This attempts to install the methods of the subclass as a category on the named class
+ (void)installObjCSafeOverrideOnClassNamed:(NSString *)targetClassName;

// Returns the name of the safe category target class
@property (nonatomic, strong, readonly, class) NSString *objCSafeOverrideTargetClassName;

@end


NS_ASSUME_NONNULL_END