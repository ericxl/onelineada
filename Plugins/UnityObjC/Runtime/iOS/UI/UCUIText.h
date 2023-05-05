//
//  UCUIText.h
//  UnityObjC
//
//  Created by Eric Liang on 4/25/23.
//

#import "UCUIGraphic.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCUIText : UCUIGraphic

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, assign) int fontSize;
@property (nonatomic, assign) UCUIFontStyle fontStyle;

@end

NS_ASSUME_NONNULL_END
