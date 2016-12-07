//
//  ImageCollectionViewCell.m
//  iosapp
//
//  Created by 王恒 on 16/9/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import <Masonry.h>
#import "UIColor+Util.h"
#import "UIView+Util.h"

@implementation ImageCollectionViewCell{
    UIButton *_deleteBtn;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addContentView];
    }
    return self;
}

-(void)addContentView{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.userInteractionEnabled = YES;
    [_deleteBtn setTitle:@"✕" forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _deleteBtn.backgroundColor = [UIColor colorWithHex:0xe35050];
    [_deleteBtn setCornerRadius:10];
    [_deleteBtn addTarget:self action:@selector(deleteMutilImage) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_deleteBtn];
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_imageView.mas_right);
        make.top.equalTo(_imageView.mas_top);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
}

-(void)setImage:(UIImage *)image{
    _image = image;
    _imageView.image = image;
}

-(void)setIsLast:(BOOL)isLast{
    _deleteBtn.hidden = isLast;
}

#pragma mark -监听
-(void)deleteMutilImage{
    self.deleteCell(self);
}
@end
