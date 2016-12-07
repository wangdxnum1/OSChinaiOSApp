//
//  OSCEditingBar.m
//  iosapp
//
//  Created by 李萍 on 16/9/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCEditingBar.h"
#import "GrowingTextView.h"
#import "Utils.h"
#import "Config.h"
#import "AppDelegate.h"

#import <ReactiveCocoa.h>

@interface OSCEditingBar ()

@end

@implementation OSCEditingBar

- (id)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    self = [super init];
    if (self) {
        //        self.backgroundColor = [UIColor grayColor];
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
        [self addBorder];
        [self setLayoutWithModeSwitchButton:hasAModeSwitchButton];
    }
    
    return self;
}


- (void)setLayoutWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    _modeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modeSwitchButton setImage:[UIImage imageNamed:@"toolbar-barSwitch"] forState:UIControlStateNormal];
    
    _inputViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_normal"] forState:UIControlStateNormal];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_pressed"] forState:UIControlStateHighlighted];
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setImage:[UIImage imageNamed:@"toolbar-image"] forState:UIControlStateNormal];
    
    _editView = [[GrowingTextView alloc] initWithPlaceholder:@"说点什么"];
    _editView.returnKeyType = UIReturnKeySend;
    [_editView setCornerRadius:4.0];
    
//    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
//    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
//        self.barTintColor = [UIColor colorWithRed:22.0/255 green:22.0/255 blue:22.0/255 alpha:1.0];
//        [_editView setBorderWidth:1.0f andColor:[UIColor borderColor]];
//        _modeSwitchButton.backgroundColor = [UIColor clearColor];
//        _inputViewButton.backgroundColor = [UIColor clearColor];
//        _cameraButton.backgroundColor = [UIColor clearColor];
//        _editView.backgroundColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
//    } else {
//        self.barTintColor = [UIColor whiteColor];
//        [_editView setBorderWidth:0.5f andColor:[UIColor colorWithHex:0xc7c7cc]];
//        _modeSwitchButton.backgroundColor = [UIColor clearColor];
//        _inputViewButton.backgroundColor = [UIColor clearColor];
//        _editView.backgroundColor = [UIColor clearColor];    //0xF5FAFA
//    }
    _editView.textColor = [UIColor blackColor];
    
    [self addSubview:_editView];
    [self addSubview:_modeSwitchButton];
    [self addSubview:_inputViewButton];
    [self addSubview:_cameraButton];
    
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_modeSwitchButton, _inputViewButton, _cameraButton, _editView);
    
    if (hasAModeSwitchButton) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_modeSwitchButton(22)]-5-[_editView]-8-[_cameraButton(25)]-8-[_inputViewButton(25)]-10-|"
                                                                     options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_modeSwitchButton]|"
                                                                     options:0 metrics:nil views:views]];
    } else {
        [_modeSwitchButton removeFromSuperview];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_editView]-8-[_cameraButton(25)]-8-[_inputViewButton(25)]-10-|"
                                                                     options:0 metrics:nil views:views]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraButton]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_inputViewButton]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_editView]-5-|" options:0 metrics:nil views:views]];
}


- (void)addBorder
{
    UIView *upperBorder = [UIView new];
    upperBorder.backgroundColor = [UIColor colorWithHex:0xc7c7cc];
    //    [UIColor borderColor];
    upperBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:upperBorder];
    
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor colorWithHex:0xc7c7cc];
    //    [UIColor borderColor];
    bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomBorder];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(upperBorder, bottomBorder);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[upperBorder]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperBorder(0.5)]->=0-[bottomBorder(0.5)]|"
                                                                 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                 metrics:nil views:views]];
}




@end

