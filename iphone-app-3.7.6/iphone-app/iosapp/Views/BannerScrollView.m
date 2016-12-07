//
//  BannerScrollView.m
//  iosapp
//
//  Created by 李萍 on 16/7/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "BannerScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"


#define BOTTOMVIEW_HEIGHT 50
#define TITLE_HEIGHT 30
#define PAGECONTROLLER_WIDTH 60

#pragma mark - 滚动图
@interface BannerScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageController;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BannerScrollView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndex = 0;
    }
    
    return self;
}

- (void)setBanners:(NSMutableArray *)banners
{
    _banners = banners;
    NSInteger arrayCount = banners.count;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * arrayCount, CGRectGetHeight(self.frame));
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_scrollView];
    
    _pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-PAGECONTROLLER_WIDTH-16, CGRectGetHeight(self.frame)-TITLE_HEIGHT, PAGECONTROLLER_WIDTH, TITLE_HEIGHT)];
    _pageController.backgroundColor = [UIColor clearColor];
    _pageController.currentPage = 0;
    _pageController.numberOfPages = arrayCount;
    _pageController.currentPageIndicatorTintColor = [UIColor newSectionButtonSelectedColor];
    _pageController.pageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageController];
    
    CGFloat imageViewWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat imageViewHeight = CGRectGetHeight(_scrollView.frame);
    
    for (int i = 0; i < arrayCount; i++) {
        BannerImageView *view = [[BannerImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, imageViewHeight)];
        view.tag = i+1;
        [_scrollView addSubview:view];
        OSCBanner *banner  = _banners[i];
        [view setContentForBanners:banner];
        
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

#pragma mark - 自动滚动
- (void)scrollToNextPage:(NSTimer *)timer
{
    _currentIndex++;
    if (_currentIndex >= _banners.count) {
        _currentIndex = 0;
    }
    _pageController.currentPage = _currentIndex;
    [_scrollView setContentOffset:CGPointMake(_currentIndex*CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
    _pageController.currentPage = _currentIndex;
}

#pragma mark - /*点击滚动图片*/
- (void)clickTopImage:(UITapGestureRecognizer *)tap
{
    [delegate clickedScrollViewBanners:tap.view.tag-1];
}

#pragma mark - 代理方法

- (void)clickScrollViewBanner:(NSInteger)bannerTag
{
    [delegate clickedScrollViewBanners:bannerTag];
}

@end

#pragma mark - 背景图片加文字
@implementation BannerImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIForSubImage:frame];
    }
    
    return self;
}

- (void)setUIForSubImage:(CGRect)frame
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _imageView.backgroundColor = [UIColor lightGrayColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-BOTTOMVIEW_HEIGHT, CGRectGetWidth(self.frame), BOTTOMVIEW_HEIGHT)];
    [self layerForCycleScrollViewTitle:bottomView];
    [self addSubview:bottomView];
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetHeight(self.frame)-TITLE_HEIGHT, CGRectGetWidth(self.frame)-96, TITLE_HEIGHT)];
    _titleLable.font = [UIFont systemFontOfSize:15];
    _titleLable.textColor = [UIColor colorWithHex:0xffffff];
    _titleLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLable];
}


- (void)setContentForBanners:(OSCBanner *)banner
{
//    [_imageView loadPortrait:[NSURL URLWithString:banner.img]];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:banner.img]];
    _titleLable.text = banner.name;
}

/* 标题背景添加渐变色 */
- (void)layerForCycleScrollViewTitle:(UIView *)bottomView
{
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[
                     (__bridge id)[UIColor colorWithHex:0x000000 alpha:0.0].CGColor,
                     (__bridge id)[UIColor colorWithHex:0x000000 alpha:0.35].CGColor,
                     ];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 0.7);
    layer.frame = bottomView.bounds;
    
    [bottomView.layer addSublayer:layer];
}


@end