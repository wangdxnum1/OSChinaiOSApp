//
//  OSCSwipableController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSwipableController.h"
#import "TitleBarView.h"
#import "OSCSwipabelCollectionController.h"

#import "Utils.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define titleBar_height 36
#define navigationBar_height 64
#define tabBar_height 44

@interface OSCSwipableController () <UIScrollViewDelegate>

@property (nonatomic, strong) TitleBarView *titleView;
@property (nonatomic, strong) OSCSwipabelCollectionController *collectionView;

@end

@implementation OSCSwipableController

- (instancetype)initWithTitle:(NSString *)title
                       Titles:(NSArray *)titles
            subViewControllers:(NSArray *)subViewControllers
                  tabbarHidden:(BOOL)isHidden
{
    self = [super init];
    if (self) {
        if (title) {self.title = title;}
        
        _titleView = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 64, screen_width, titleBar_height) andTitles:titles];
        _titleView.backgroundColor = [UIColor titleBarColor];
        [self.view addSubview:_titleView];
        
        CGRect frame = (CGRect){{0, navigationBar_height + titleBar_height}, {screen_width, CGRectGetHeight(self.view.frame)-titleBar_height - navigationBar_height - (isHidden ? tabBar_height : 0)}};
        _collectionView = [[OSCSwipabelCollectionController alloc] initWithFrame:frame SubController:subViewControllers tabbarHidden:isHidden];
        _collectionView.view.frame = frame;
        
        [self addChildViewController:_collectionView];
        [self.view addSubview:_collectionView.view];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
