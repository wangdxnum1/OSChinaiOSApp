//
//  ActivityHeadView.m
//  iosapp
//
//  Created by 李萍 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityHeadView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UILabel+VerticalAlign.h"
#import "Utils.h" 

#import <Masonry.h>

@interface ActivityHeadView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageCtl;

@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@property NSTimer *timer;

@end

@implementation ActivityHeadView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndex = 0;
    }
    return self;
}

- (void)setUpScrollView:(NSMutableArray *)bannners
{
    _banners = bannners;
    
    NSInteger arrayCount = bannners.count;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * arrayCount, CGRectGetHeight(self.frame));
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_scrollView];
    
    _pageCtl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-27, CGRectGetWidth(self.frame), 27)];
    _pageCtl.backgroundColor = [UIColor clearColor];
    _pageCtl.currentPage = 0;
    _pageCtl.numberOfPages = arrayCount;
    _pageCtl.currentPageIndicatorTintColor = [UIColor newSectionButtonSelectedColor];
    _pageCtl.pageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageCtl];
    
    CGFloat imageViewWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat imageViewHeight = CGRectGetHeight(_scrollView.frame);
    
    for (int i = 0; i < arrayCount; i++) {
        BottomImageView *view = [[BottomImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, imageViewHeight)];
        view.tag = i+1;
        [_scrollView addSubview:view];
        OSCBanner *banner  = bannners[i];
        [view setContentForTopImages:banner];
        
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImage:)]];
    }
    if (arrayCount > 1) {
        if(!self.timer) {
            self.timer = [NSTimer timerWithTimeInterval:4.0f target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
}

- (void)setBanners:(NSMutableArray *)banners
{
    [self setUpScrollView:banners];
}

#pragma mark - 自动滚动
- (void)scrollToNextPage:(NSTimer *)timer
{
    _currentIndex++;
    if (_currentIndex >= _banners.count) {
        _currentIndex = 0;
    }
    _pageCtl.currentPage = _currentIndex;
    [_scrollView setContentOffset:CGPointMake(_currentIndex*CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
    _pageCtl.currentPage = _currentIndex;
}

#pragma mark - /*点击滚动图片*/
- (void)clickTopImage:(UITapGestureRecognizer *)tap
{
    [delegate clickScrollViewBanner:tap.view.tag-1];
}

#pragma mark - 代理方法

- (void)clickScrollViewBanner:(NSInteger)bannerTag
{
    [delegate clickScrollViewBanner:bannerTag];
}

@end

//带背景图片的UIImageView
@implementation BottomImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI:frame];
    }
    return self;
}

- (void)setUpUI:(CGRect)frame
{
    _bottomImage = [[UIImageView alloc] initWithFrame:frame];
    _bottomImage.contentMode = UIViewContentModeScaleAspectFill;
    _bottomImage.backgroundColor = [UIColor lightGrayColor];
    _bottomImage.clipsToBounds = YES;
    [self addSubview:_bottomImage];
   
    _subImageView = [[UIImageView alloc] init];
    [self addSubview:_subImageView];
    
    _titleLable = [[UILabel alloc] init];
    _titleLable.font = [UIFont systemFontOfSize:18];
    _titleLable.numberOfLines = 0;
    _titleLable.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLable.textColor = [UIColor colorWithHex:0xffffff];
    [self addSubview:_titleLable];
    
    _descLable = [[UILabel alloc] init];
    _descLable.font = [UIFont systemFontOfSize:14];
    _descLable.numberOfLines = 0;
    _descLable.lineBreakMode = NSLineBreakByWordWrapping;
    _descLable.textColor = [UIColor colorWithHex:0xffffff];
    [self addSubview:_descLable];
    
    [self setLayout];
}

- (void)setLayout
{
    [_bottomImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_subImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self).offset(16);
        make.width.equalTo(@120);
        make.height.equalTo(@180);
    }];
    
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16);
        make.left.equalTo(_subImageView.mas_right).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.equalTo(@50);
    }];
    
    [_descLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_subImageView.mas_right).offset(16);
        make.top.equalTo(_titleLable.mas_bottom).offset(16);
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-27);
    }];
}

- (void)setContentForTopImages:(OSCBanner *)banner
{
    [_subImageView loadPortrait:[NSURL URLWithString:banner.img]];

    [_bottomImage loadPortrait:[NSURL URLWithString:banner.img]];
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    effectView.alpha = 0.85;
    effectView.frame = _bottomImage.bounds;
    [_bottomImage addSubview:effectView];

    _titleLable.text = banner.name;
    _descLable.text = banner.detail;
}


@end
