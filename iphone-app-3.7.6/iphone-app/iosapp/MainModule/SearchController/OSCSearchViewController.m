//
//  OSCSearchViewController.m
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSearchViewController.h"
#import "OSCSearchResultTableViewController.h"
#import "UINavigationBar+BackgroundColor.h"
#import "UIColor+Util.h"
#import "Utils.h"
#import "UIImage+Util.h"
#import <AFNetworking.h>

#define kScreenSize [UIScreen mainScreen].bounds.size
#define rightItemWidth 35

@interface OSCSearchViewController ()<UISearchBarDelegate, UIScrollViewDelegate,ResultContrllerDelegate>
{
    UIButton *_cancelBtn;
}

@property (nonatomic,strong)NSArray *titleArray;

@property (nonatomic,strong)SearchTitleBar *titleBar;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)UIActivityIndicatorView *activityView;
@property (nonatomic,strong)UIBarButtonItem *rightItem;

@end

@implementation OSCSearchViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithHex:0xf6f6f6]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor navigationbarColor];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor colorWithHex:0xf6f6f6]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [Utils createImageWithColor:[UIColor colorWithHex:0xf6f6f6]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setSelf];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [Utils createImageWithColor:[UIColor navigationbarColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar lt_reset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleArray = @[@"博客",@"软件",@"资讯",@"问答",@"找人"];
    [self createCancelBtn];
    [self setSelf];
    [self addContentView];
}

-(void)addContentView{
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索博客、软件、资讯、问答、人";
    UIView *textField = [[[[_searchBar subviews] lastObject] subviews] lastObject];
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.layer.borderWidth = 1;
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
    
    for (int i = 0; i < _titleArray.count; i ++) {
        OSCSearchResultTableViewController *resultVC = [[OSCSearchResultTableViewController alloc] initWithStyle:UITableViewStylePlain withType:i];
        resultVC.resultDelegate = self;
        [self addChildViewController:resultVC];
    }
    
    [self.view addSubview:self.titleBar];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleBar.frame), kScreenSize.width, kScreenSize.height - CGRectGetMaxY(self.titleBar.frame))];
    _scrollView.contentSize = CGSizeMake(kScreenSize.width * _titleArray.count, kScreenSize.height - CGRectGetMaxY(self.titleBar.frame) - 64);
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    UIViewController *childVC = [[self childViewControllers] objectAtIndex:0];
    childVC.view.frame = CGRectMake(0, 0, kScreenSize.width, _scrollView.frame.size.height);
    [_scrollView addSubview:childVC.view];
}

-(void)setSelf{
    self.view.backgroundColor = [UIColor whiteColor];
    _rightItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelBtn];
    self.navigationItem.rightBarButtonItem = _rightItem;
}

-(void)createCancelBtn{
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame = CGRectMake(0, 0, rightItemWidth, 26);
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_cancelBtn setTitleColor:[UIColor navigationbarColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark searchBar代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    NSArray *childVC = [self childViewControllers];
    for (OSCSearchResultTableViewController *resultVC in childVC) {
        resultVC.keyWord = _searchBar.text;
    }
    NSInteger index = _scrollView.contentOffset.x / kScreenSize.width;
    OSCSearchResultTableViewController *currentVC = childVC[index];
    [currentVC getDataWithisRefresh:YES];
}

#pragma --mark scrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = [scrollView contentOffset].x / kScreenSize.width;
    UIButton *btn = [self.titleBar viewWithTag:index + 11];
    [self.titleBar selectBtn:btn];
}

#pragma --mark ResultController代理
/**当滚动时调用*/
-(void)resultTableViewDidScroll{
    [_searchBar resignFirstResponder];
}

/**当开始加载时*/
-(void)resultVCBeginRequest{
    _rightItem.customView = self.activityView;
}

/**当加载完成时*/
-(void)resultVCCompleteRequest{
    [self stopWaiting];
}

/**当点击cell时*/
-(void)resultClickCellWithContoller:(UIViewController *)targetVC withHref:(NSString *)href{
    if(targetVC){
        [self.navigationController pushViewController:targetVC animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:href] name:nil];
        self.navigationController.navigationBar.translucent = YES;
    }
}

#pragma --mark 事件处理
-(void)cancelClick{
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)stopWaiting{
    _rightItem.customView = _cancelBtn;
}

#pragma --mark lazy load
-(SearchTitleBar *)titleBar{
    if (!_titleBar) {
        _titleBar = [[SearchTitleBar alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, 40) WithTitles:_titleArray];
        __weak OSCSearchViewController *weakSelf = self;
        _titleBar.btnClick = ^(NSInteger index){
            CGPoint point = CGPointMake(index * kScreenSize.width, 0);
            [weakSelf.scrollView setContentOffset:point animated:YES];
            OSCSearchResultTableViewController *vc = [[weakSelf childViewControllers] objectAtIndex:index];
            if(![weakSelf.scrollView.subviews containsObject:vc.view]){
                vc.view.frame = CGRectMake(index * kScreenSize.width, 0, kScreenSize.width, weakSelf.scrollView.frame.size.height);
                [weakSelf.scrollView addSubview:vc.view];
            }
            [vc controllerChanged];
        };
    }
    return _titleBar;
}

-(UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, rightItemWidth, 26)];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        _activityView.color = [UIColor navigationbarColor];
        [_activityView startAnimating];
    }
    return _activityView;
}

@end





@implementation SearchTitleBar

-(instancetype)initWithFrame:(CGRect)frame WithTitles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        [self addContentViewWithTitles:titles];
    }
    return self;
}

-(void)addContentViewWithTitles:(NSArray *)titles{
    for (int i = 0; i < titles.count ; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * kScreenSize.width/titles.count, 0, kScreenSize.width/titles.count, 40);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:0x6a6a6a] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor navigationbarColor] forState:UIControlStateSelected];
        button.tag = 11 + i;
        [button addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.selected = YES;
        }
        [self addSubview:button];
    }
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 40);
    CGContextAddLineToPoint(context, kScreenSize.width, 40);
    [[UIColor lightGrayColor] setStroke];
    CGContextStrokePath(context);
}

#pragma --mark 事件
-(void)selectBtn:(UIButton *)btn{
    NSInteger index = btn.tag - 11;
    NSArray *btnArray = [self subviews];
    for (int i = 0; i<btnArray.count; i++) {
        if (index == i) {
            btn.selected = YES;
        }else{
            UIButton *otherBtn = (UIButton *)[self viewWithTag:i + 11];
            otherBtn.selected = NO;
        }
    }
    self.btnClick(index);
}

@end
