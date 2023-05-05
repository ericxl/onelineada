//
//  UCUIGraphic.h
//  UnityObjC
//
//  Created by Eric Liang on 4/30/23.
//

#import "UCMonoBehaviour.h"

@class UCCanvas;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UCUIFontStyle) {
    UCUIFontStyleNormal,
    UCUIFontStyleBold,
    UCUIFontStyleItalic,
    UCUIFontStyleBoldAndItalic
};

typedef NS_ENUM(NSInteger, UCUITMProFontStyles) {
    UCUITMProFontStylesNormal = 0x0,
    UCUITMProFontStylesBold = 0x1,
    UCUITMProFontStylesItalic = 0x2,
    UCUITMProFontStylesUnderline = 0x4,
    UCUITMProFontStylesLowerCase = 0x8,
    UCUITMProFontStylesUpperCase = 0x10,
    UCUITMProFontStylesSmallCaps = 0x20,
    UCUITMProFontStylesStrikethrough = 0x40,
    UCUITMProFontStylesSuperscript = 0x80,
    UCUITMProFontStylesSubscript = 0x100,
    UCUITMProFontStylesHighlight = 0x200
};

@interface UCUIGraphic : UCMonoBehaviour

@property (nonatomic, strong, readonly, nullable) UCCanvas *canvas;

@end

NS_ASSUME_NONNULL_END
