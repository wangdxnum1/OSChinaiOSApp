//
//  OSCRandomCenterController.m
//  iosapp
//
//  Created by Graphic-one on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCRandomCenterController.h"

#import "ShakingViewController.h"
#import "OSCRewardViewController.h"

#import "UIColor+Util.h"
#import <UIView+YYAdd.h>

#define TOOL_BAR_HEIGHT 100

#define GIFT_BUTTON_TAG 1001
#define INFORMATION_BUTTON_TAG 1002

#define SCREEN_PADDING 15
#define iamge_SPACE_label 6

@interface OSCRandomCenterController ()
@property (nonatomic,strong) OSCRewardViewController* rewardVC;
@property (nonatomic,strong) ShakingViewController* shakingVC;
@end

@implementation OSCRandomCenterController{
    __weak UILabel* _giftLabel;
    __weak UILabel* _informationLabel;
    
    __weak UIButton* _giftBtn;
    __weak UIButton* _informationBtn;
    __weak UIButton* _isSelectedBtn;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;

        self.navigationItem.title = @"摇一摇";
        _rewardVC = [[OSCRewardViewController alloc]init];
        _shakingVC = [[ShakingViewController alloc]init];
    }
    return self;
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
    [self settingSelectedButton:_giftBtn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
}

- (void)cancelButtonClicked
{
    if (self.navigationController.viewControllers.count <= 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark --- layoutUI
- (void)layoutUI{
    UIView* toolBar = [[UIView alloc]initWithFrame:(CGRect){{0,self.view.bounds.size.height - TOOL_BAR_HEIGHT},{self.view.bounds.size.width,TOOL_BAR_HEIGHT}}];
    toolBar.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
    [self.view addSubview:toolBar];
    
    UILabel* giftLabel = [UILabel new];
    giftLabel.font = [UIFont systemFontOfSize:15];
    giftLabel.textAlignment = NSTextAlignmentCenter;
    giftLabel.textColor = [UIColor blackColor];
    giftLabel.text = @"礼品";
    giftLabel.size = (CGSize){toolBar.bounds.size.width * 0.5 , 20};
    giftLabel.left = toolBar.left;
    giftLabel.bottom = TOOL_BAR_HEIGHT - 10;;
    _giftLabel = giftLabel;
    [toolBar addSubview:giftLabel];
    
    UILabel* informationLabel = [UILabel new];
    informationLabel.font = [UIFont systemFontOfSize:15];
    informationLabel.textAlignment = NSTextAlignmentCenter;
    informationLabel.textColor = [UIColor blackColor];
    informationLabel.text = @"资讯";
    informationLabel.size = (CGSize){toolBar.bounds.size.width * 0.5 , 20};
    informationLabel.left = toolBar.left + self.view.bounds.size.width * 0.5;
    informationLabel.bottom = TOOL_BAR_HEIGHT - 10;
    _informationLabel = informationLabel;
    [toolBar addSubview:informationLabel];
    
    UIButton* giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    giftBtn.frame = (CGRect){{0,0},{self.view.bounds.size.width * 0.5,TOOL_BAR_HEIGHT}};
    giftBtn.tag = GIFT_BUTTON_TAG;
    [giftBtn setImage:[UIImage imageNamed:@"btn_shake_gift"] forState:UIControlStateNormal];
    [giftBtn setImage:[UIImage imageNamed:@"btn_shake_gift_actived"] forState:UIControlStateSelected];
    [giftBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, 0)];
    [giftBtn addTarget:self action:@selector(settingSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    _giftBtn = giftBtn;
    [toolBar addSubview:_giftBtn];
    
    UIButton* informationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    informationBtn.frame = (CGRect){{self.view.bounds.size.width * 0.5,0},{self.view.bounds.size.width * 0.5,TOOL_BAR_HEIGHT}};
    informationBtn.tag = INFORMATION_BUTTON_TAG;
    [informationBtn setImage:[UIImage imageNamed:@"btn_shake_info"] forState:UIControlStateNormal];
    [informationBtn setImage:[UIImage imageNamed:@"btn_shake_info_actived"] forState:UIControlStateSelected];
    [informationBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, 0)];
    [informationBtn addTarget:self action:@selector(settingSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    _informationBtn = informationBtn;
    [toolBar addSubview:_informationBtn];
}

#pragma mark --- change selected button
- (void)settingSelectedButton:(UIButton* )btn{
    if (_isSelectedBtn == btn) { return; }
    
    NSInteger btnTag = btn.tag;
    
    for (UIViewController* childVC in self.childViewControllers) {
        [childVC removeFromParentViewController];
        [childVC.view removeFromSuperview];
    }
    
    if (btnTag == GIFT_BUTTON_TAG) {
        _giftLabel.textColor = [UIColor blackColor];
        _informationLabel.textColor = [UIColor grayColor];
        _giftBtn.selected = YES;
        _informationBtn.selected = NO;
        _isSelectedBtn = _giftBtn;

        _shakingVC.isShaking = YES;
        _rewardVC.isShaking = NO;
        
        [self addChildViewController:_rewardVC];
        UIView* childVC_View = _rewardVC.view;
        childVC_View.frame = (CGRect){{0,0},{self.view.bounds.size.width,self.view.bounds.size.height - TOOL_BAR_HEIGHT}};
        [self.view addSubview:childVC_View];
    }else if (btnTag == INFORMATION_BUTTON_TAG){
        _giftLabel.textColor = [UIColor grayColor];
        _informationLabel.textColor = [UIColor blackColor];
        _informationBtn.selected = YES;
        _giftBtn.selected = NO;
        _isSelectedBtn = _informationBtn;

        _shakingVC.isShaking = NO;
        _rewardVC.isShaking = YES;
        
        [self addChildViewController:_shakingVC];
        UIView* childVC_View = _shakingVC.view;
        childVC_View.frame = (CGRect){{0,0},{self.view.bounds.size.width,self.view.bounds.size.height - TOOL_BAR_HEIGHT}};
        [self.view addSubview:childVC_View];
    }else{
        return;
    }
}

- (void)dealloc{
    _rewardVC.isShaking = YES;
    _shakingVC.isShaking = YES;
    _rewardVC = nil;
    _shakingVC = nil;
}

@end
