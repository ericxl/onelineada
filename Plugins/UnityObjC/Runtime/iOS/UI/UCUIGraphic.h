//
//  UCUIGraphic.h
//  UnityObjC
//
//  Created by Eric Liang on 4/30/23.
//

#import "UCMonoBehaviour.h"

@class UCCanvas;

NS_ASSUME_NONNULL_BEGIN

@interface UCUIGraphic : UCMonoBehaviour

@property (nonatomic, strong, readonly, nullable) UCCanvas *canvas;

@end

NS_ASSUME_NONNULL_END
