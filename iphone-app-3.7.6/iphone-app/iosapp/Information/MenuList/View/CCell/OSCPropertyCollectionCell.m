//
//  OSCPropertyCollectionCell.m
//  iosapp
//
//  Created by 王恒 on 16/10/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPropertyCollectionCell.h"

#import "UIColor+Util.h"

@interface OSCPropertyCollectionCell ()

{
    UILabel *_titleLabel;
    UIButton *_deleteBtn;
}

@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,assign) BOOL isUable;
@property (nonatomic,assign) CellType cellType;

@end

@implementation OSCPropertyCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addContentView];
    }
    return self;
}

-(void)addContentView{
    _titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _titleLabel.font = [UIFont systemFontOfSize:13.0];
    _titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.layer.cornerRadius = self.contentView.bounds.size.height / 2;
    _titleLabel.layer.borderWidth = 1;
    _titleLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _titleLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    _titleLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:_titleLabel];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(0, 0, 28, 28);
    _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 14, 14);
    [_deleteBtn setImage:[UIImage imageNamed:@"ic_unsubscribe.pdf"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    _deleteBtn.hidden = YES;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

#pragma 实现
-(void)deleteClick{
    if([self.delegate respondsToSelector:@selector(deleteBtnClickWithCell:)]){
        [self.delegate deleteBtnClickWithCell:self];
    }
}

-(void)beginEding{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = 0.2;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAX_CANON;
    int direction = arc4random() % 2;
    if (direction == 0) {
        animation.values = @[@(0),@(-M_PI / 90),@(0),@(M_PI / 90),@(0)];
    }else{
        animation.values = @[@(0),@(M_PI / 90),@(0),@(-M_PI / 90),@(0)];
    }
    [self.layer addAnimation:animation forKey:@"animation"];
    _deleteBtn.hidden = NO;
}

-(void)endEding{
    [self.layer removeAnimationForKey:@"animation"];
    _deleteBtn.hidden = YES;
}

-(void)setCellType:(CellType)cellType WithIsUnable:(BOOL)isUnable{
    _isUable = isUnable;
    _cellType = cellType;
    switch (_cellType) {
        case CellTypeNomal:{
            _titleLabel.textColor = [UIColor colorWithHex:0x111111];
            if (!_isUable) {
                _titleLabel.layer.borderColor = [[UIColor colorWithHex:0xcdcdcd] CGColor];
            }else{
                _titleLabel.layer.borderColor = [[UIColor colorWithRed:205/225.0 green:205/225.0 blue:205/225.0 alpha:0.4] CGColor];
                _titleLabel.backgroundColor = [UIColor clearColor];
            }
        }
            break;
        case CellTypeSelect:{
            _titleLabel.textColor = [UIColor navigationbarColor];
            if (!_isUable) {
                _titleLabel.layer.borderColor = [[UIColor navigationbarColor] CGColor];
            }else{
                _titleLabel.layer.borderColor = [[UIColor colorWithRed:205/225.0 green:205/225.0 blue:205/225.0 alpha:0.4] CGColor];
                _titleLabel.backgroundColor = [UIColor clearColor];
            }
        }
            break;
        case CellTypeSecond:{
            _titleLabel.textColor = [UIColor colorWithHex:0x111111];
            _titleLabel.layer.borderColor = [[UIColor colorWithHex:0xcdcdcd] CGColor];
        }
            break;
        default:
            break;
    }
}

- (CellType)getType{
    return _cellType;
}

@end
