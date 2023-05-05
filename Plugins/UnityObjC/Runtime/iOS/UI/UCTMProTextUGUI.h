//
//  UCTMProTextUGUI.h
//  UnityObjC
//
//  Created by Eric Liang on 5/4/23.
//

#import "UCUIGraphic.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCTMProTextUGUI : UCUIGraphic

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) UCUITMProFontStyles fontStyle;

@end

NS_ASSUME_NONNULL_END
