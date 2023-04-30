//
//  UnityViewAccessibility.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/30/23.
//

#import <Foundation/Foundation.h>
#import "UnityAXSafeCategory.h"

UnityAXDeclareSafeCategory(UnityViewAccessibility)

@interface UnityViewAccessibility ()

- (NSArray *)unityViewAccessibilityElements;

@end
