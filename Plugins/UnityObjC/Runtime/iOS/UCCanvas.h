//
//  UCCanvas.h
//  UnityObjC
//
//  Created by Eric Liang on 4/26/23.
//

#import "UCBehaviour.h"

@class UCCamera;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UCCanvasRenderMode) {
    UCCanvasRenderModeScreenSpaceOverlay,
    UCCanvasRenderModeScreenSpaceCamera,
    UCCanvasRenderModeWorldSpace
};

@interface UCCanvas : UCBehaviour

@property (nonatomic, assign, readonly) UCCanvasRenderMode renderMode;
@property (nonatomic, strong, readonly) UCCamera *worldCamera;

@end

NS_ASSUME_NONNULL_END
