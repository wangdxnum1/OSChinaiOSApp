//
//  OSCMessageCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageCell.h"
#import "OSCMessageCenter.h"
#import "ImageDownloadHandle.h"
#import "UIColor+Util.h"
#import "Utils.h"

#import "UIImageView+RadiusHandle.h"
#import "NSDate+Util.h"
#import "NSString+Util.h"
#import <YYKit.h>

#define OPERATION_BUTTON_W 70
#define OFFEST_MAX_LEFT 8
#define OFFEST_MAX_RIGHT OPERATION_BUTTON_W * 2

@interface OSCMessageCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation OSCMessageCell{
    __weak IBOutlet UIButton *_setTopButton;
    __weak IBOutlet UIButton *_deleteButton;
    
    BOOL _trackingTouch_userPortrait;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_userPortraitImageView handleCornerRadiusWithRadius:22.5];
    
    _openSlidingOperation = NO;
    
    [_setTopButton setTitle:@"置顶" forState:UIControlStateNormal];
    [_setTopButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_setTopButton setBackgroundColor:[UIColor orangeColor]];
    
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteButton setBackgroundColor:[UIColor redColor]];
    
//    暂时性操作
    _setTopButton.hidden = YES;
    _deleteButton.hidden = YES;
    
//    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)];
//    [_bgView addGestureRecognizer:pan];
}

+ (instancetype)returnReuseMessageCellWithTableView:(UITableView *)tableView
                                          indexPath:(NSIndexPath *)indexPath
                                         identifier:(NSString *)reuseIdentifier
{
    OSCMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView.backgroundColor = [UIColor newCellColor];;
        self.contentView.backgroundColor = [UIColor newCellColor];;
        self.backgroundColor = [UIColor newCellColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    }
    return self;
}
#pragma mark --- Pan Operation
- (void)handlePanGestures:(UIPanGestureRecognizer* )pan{
    if (!_openSlidingOperation) { return ; }
    CGPoint point = [pan translationInView:pan.view];
    CGFloat x_offest = point.x;
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        [self _resetTranslation];
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (x_offest > 0) {
            CGFloat reselt_x = x_offest < OFFEST_MAX_LEFT ? x_offest : OFFEST_MAX_LEFT;
            [_bgView setTransform:CGAffineTransformMakeTranslation(reselt_x, 0)];
//            _bgView.centerX += reselt_x;
        }else{
            CGFloat reselt_x = x_offest > -OFFEST_MAX_RIGHT ? x_offest : -OFFEST_MAX_RIGHT;
            [_bgView setTransform:CGAffineTransformMakeTranslation(reselt_x, 0)];
//            _bgView.centerX += reselt_x;
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (x_offest > 0) {
            [self _resetTranslation];
        }else{
            CGFloat reselt_x = x_offest > -OFFEST_MAX_RIGHT ? 0 : -OFFEST_MAX_RIGHT;
            [_bgView setTransform:CGAffineTransformMakeTranslation(reselt_x, 0)];
//            if (x_offest > - (OFFEST_MAX_RIGHT * 0.5)) {
//                [self _resetTranslation];
//            }else{
//                _bgView.centerX += -OFFEST_MAX_RIGHT;
//            }
        }
    }
    [pan setTranslation:point inView:_bgView];
}
#pragma mark --- reset the location
- (void)resetTheLocation{
    [self _resetTranslation];
}
- (void)_resetTranslation{
    [_bgView setTransform:CGAffineTransformMakeTranslation(0, 0)];
}

#pragma mark --- set Model
- (void)setMessageItem:(MessageItem *)messageItem{
    _messageItem = messageItem;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:messageItem.sender.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:messageItem.sender.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [_userPortraitImageView setImage:image];
           });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_userPortraitImageView setImage:portraitImage];
        });
    }
    
    _userNameLabel.text = messageItem.sender.name;
    _timeLabel.text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:messageItem.pubDate] timeAgoSinceNow]]].string;
    switch (messageItem.type) {
        case OSCPrivateTypeText:
            _descLabel.text = [messageItem.content deleteHTMLTag];
            break;
        case OSCPrivateTypeImage:
            _descLabel.text = @"[图片]";
            break;
        case OSCPrivateTypeFile:
            _descLabel.text = @"[文件]";
            break;
            
        default:
            break;
    }
}

#pragma mark --- touch
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self _resetTranslation];
//    [super touchesBegan:touches withEvent:event];
//}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:_userPortraitImageView];
    if (CGRectContainsPoint(_userPortraitImageView.bounds, p)) {
        _trackingTouch_userPortrait = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(messageCellDidClickUserPortrait:)]) {
            [_delegate messageCellDidClickUserPortrait:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_userPortrait) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark --- operation Button Method
- (IBAction)deleteOperation:(UIButton *)sender {
    [self _resetTranslation];
    if ([_delegate respondsToSelector:@selector(messageCellDidClickDelete:)]) {
        [_delegate messageCellDidClickDelete:self];
    }
}
- (IBAction)setTopOperation:(UIButton *)sender {
    [self _resetTranslation];
    if ([_delegate respondsToSelector:@selector(messageCellDidClickSetTop:)]) {
        [_delegate messageCellDidClickSetTop:self];
    }
}

@end
