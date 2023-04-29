//
//  UnityAXFrameUtilities.h
//  UnityAXUtils
//
//  Created by Eric Liang on 4/28/23.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UnityObjC.h"

NS_ASSUME_NONNULL_BEGIN
@interface UCRectTransform (FrameExtensions)
- (CGRect)unityAXFrameInScreenSpace;
@end

@interface UCSpriteRenderer (FrameExtensions)
- (CGRect)unityAXFrameInScreenSpace;
@end

NS_ASSUME_NONNULL_END
