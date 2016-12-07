//
//  CommentTextView.h
//  iosapp
//
//  Created by 王恒 on 16/11/8.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentTextViewDelegate <NSObject>

//- (void)textViewChangeWithTargetHeight:(float)height;
//
//- (void)clickReturn;

- (void)ClickTextViewWithString:(NSString *)string;
- (void)ClickTextViewWithAttribute:(NSAttributedString *)attribute;

@end

@interface CommentTextView : UITextView

@property (nonatomic,strong) NSString *placeholder;

//@property (nonatomic,assign) NSInteger maxLenth;

@property (nonatomic,assign) id<CommentTextViewDelegate> commentTextViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame
              WithPlaceholder:(NSString *)placeholder
                     WithFont:(UIFont *)font;

- (void)handleAttributeWithString:(NSString *)textString;

- (void)handleAttributeWithAttribute:(NSAttributedString *)attribute;

- (NSString *)getPlace;

@end
