//
//  OSCSyntheticalController.m
//  iosapp
//
//  Created by 王恒 on 16/10/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSyntheticalController.h"
#import "SyntheticalTitleBarView.h"
#import "OSCPropertyCollection.h"
#import "Utils.h"
#import "OSCInformationListCollectionViewController.h"
#import "OSCFunctionIntroManager.h"

#import "UIColor+Util.h"

#import "OSCMenuItem.h"

#define kTitleHeigh 36
#define kScreenSize [UIScreen mainScreen].bounds.size
#define kAnimationTime 0.4

@interface OSCSyntheticalController () <SyntheticalTitleBarDelegate,OSCPropertyCollectionDelegate,InformationListCollectionDelegate>

{
    UILabel *_label;
    UIButton *_editBtn;
}

@property (nonatomic,strong) SyntheticalTitleBarView *titleView;
@property (nonatomic, strong) OSCPropertyCollection *collectionView;
@property (nonatomic, strong) UIView *propertyTitleView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic,strong) OSCInformationListCollectionViewController *informationListController;

@property (nonatomic,strong)NSArray *selectArray;
@property (nonatomic,strong)NSArray *unSelectArray;

@end

@implementation OSCSyntheticalController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.translucent = YES;
    [super viewWillAppear:animated];
    if (_collectionView && _collectionView.isEditing) {
        [_collectionView changeStateWithEdit:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selectArray = [Utils allSelectedMenuNames];
    self.navigationItem.title = @"综合";
    self.view.backgroundColor = [UIColor whiteColor];
    _titleView = [[SyntheticalTitleBarView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kTitleHeigh) WithTitles:_selectArray];
    _titleView.delegate = self;
    [self.view addSubview:_titleView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.itemSize = CGSizeMake(kScreenSize.width, kScreenSize.height - CGRectGetMaxY(_titleView.frame) - 49);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 49, 0);
    _informationListController = [[OSCInformationListCollectionViewController alloc] initWithCollectionViewLayout:layout];
    _informationListController.informationListCollectionDelegate = self;
    _informationListController.menuItem = [Utils conversionMenuItemsWithMenuNames:_selectArray];
    [self addChildViewController:_informationListController];
    
    _informationListController.collectionView.frame = CGRectMake(0, CGRectGetMaxY(_titleView.frame), kScreenSize.width, kScreenSize.height - CGRectGetMaxY(_titleView.frame));
    [self.view addSubview:_informationListController.collectionView];
    
    OSCIntroView* introView = [OSCFunctionIntroManager showIntroPage];
    introView.didClickAddButtonBlock = ^(){
        [self.titleView addClick];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark SyntheticalTitleBarDelegate
- (void)addBtnClickWithIsBeginEdit:(BOOL)isEdit{
    if (isEdit) {
        [UIView animateWithDuration:kAnimationTime animations:^{
            self.tabBarController.tabBar.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, self.tabBarController.tabBar.bounds.size.height);
        } completion:^(BOOL finished) {
            [_titleView endAnimation];
        }];
        [self beginChoseProperty];
    }else{
        [UIView animateWithDuration:kAnimationTime animations:^{
            self.tabBarController.tabBar.frame = CGRectMake(0, kScreenSize.height - self.tabBarController.tabBar.bounds.size.height, kScreenSize.width, self.tabBarController.tabBar.bounds.size.height);
        } completion:^(BOOL finished) {
            [_titleView endAnimation];
        }];
        [self endChoseProperty];
    }
}

- (void)titleBtnClickWithIndex:(NSInteger)index{
    _currentIndex = index;
    [_informationListController.collectionView setContentOffset:CGPointMake(index * kScreenSize.width, 0)];
}

- (void)closeSyntheticalTitleBarView{
    [_collectionView endEditing:YES];
    _selectArray = [_collectionView CompleteAllEditings];
    [_titleView reloadAllButtonsOfTitleBarWithTitles:_selectArray];
    [Utils updateUserSelectedMenuListWithMenuNames:_selectArray];
    _informationListController.menuItem = [Utils conversionMenuItemsWithMenuNames:_selectArray];
    _currentIndex = [_collectionView getSelectIdenx];
    [_titleView scrollToCenterWithIndex:_currentIndex];
    [_informationListController.collectionView setContentOffset:CGPointMake(_currentIndex * kScreenSize.width, 0)];
}

#pragma --mark OSCPropertyCollectionDelegate
-(void)clickCellWithIndex:(NSInteger)index{
    _currentIndex = index;
    [self.titleView reloadAllButtonsOfTitleBarWithTitles:[_collectionView CompleteAllEditings]];
    [self.titleView ClickCollectionCellWithIndex:index];
    [self addBtnClickWithIsBeginEdit:NO];
    _selectArray = [_collectionView CompleteAllEditings];
    [Utils updateUserSelectedMenuListWithMenuNames:_selectArray];
    _informationListController.menuItem = [Utils conversionMenuItemsWithMenuNames:_selectArray];
    [_informationListController.collectionView setContentOffset:CGPointMake(index * kScreenSize.width, 0)];
}

- (void)beginEdit{
    [self editBtnClick:_editBtn];
}

#pragma --mark OSCPropertyCollectionDelegate
- (void)ScrollViewDidEndWithIndex:(NSInteger)index{
    _currentIndex = index;
    [self.titleView scrollToCenterWithIndex:index];
}

#pragma --mark 事件

-(void)editBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    [self.collectionView changeStateWithEdit:btn.selected];
    if (btn.selected) {
        _label.text = @"拖动排序";
    }else{
        _label.text = @"切换栏目";
    }
}

-(void)beginChoseProperty{
    [self.view addSubview:self.collectionView];
    [_titleView addSubview:self.propertyTitleView];
    [self.view bringSubviewToFront:_titleView];
    [UIView animateWithDuration:kAnimationTime animations:^{
        self.propertyTitleView.alpha = 1;
        self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(_titleView.frame), kScreenSize.width, kScreenSize.height - CGRectGetMaxY(_titleView.frame));
    }];
}

-(void)endChoseProperty{
    float height = kScreenSize.height - CGRectGetMaxY(_titleView.frame);
    [UIView animateWithDuration:kAnimationTime animations:^{
        self.propertyTitleView.alpha = 0;
        self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(_titleView.frame) - height, kScreenSize.width, height);
    } completion:^(BOOL finished) {
        [self.collectionView removeFromSuperview];
        [self.propertyTitleView removeFromSuperview];
        self.propertyTitleView = nil;
        self.collectionView = nil;
    }];
}

- (void)beginRefresh{
    [_informationListController beginRefreshWithIndex:_currentIndex];
}

#pragma --mark lazyLoad
-(OSCPropertyCollection *)collectionView{
    if (!_collectionView) {
        float height = kScreenSize.height - CGRectGetMaxY(_titleView.frame);
        _collectionView = [[OSCPropertyCollection alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleView.frame) - height, kScreenSize.width, height) WithSelectIndex:_currentIndex];
        _collectionView.propertyCollectionDelegate = self;
    }
    return _collectionView;
}

-(UIView *)propertyTitleView{
    if (!_propertyTitleView) {
        _propertyTitleView = [[UIView alloc] initWithFrame:_titleView.titleBarFrame];
        _propertyTitleView.backgroundColor = [UIColor titleBarColor];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, _propertyTitleView.bounds.size.height)];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor colorWithHex:0x9d9d9d];
        _label.text = @"切换栏目";
        [_propertyTitleView addSubview:_label];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(_titleView.titleBarFrame.size.width - 60, _titleView.titleBarFrame.size.height/2 - 12, 60, 24);
        [_editBtn setTitle:@"排序删除" forState:UIControlStateNormal];
        [_editBtn setTitle:@"完成" forState:UIControlStateSelected];
        [_editBtn setBackgroundImage:[Utils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_editBtn setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forState:UIControlStateHighlighted];
        [_editBtn setTitleColor:[UIColor navigationbarColor] forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _editBtn.layer.cornerRadius = 4;
        _editBtn.layer.masksToBounds = YES;
        _editBtn.layer.borderColor = [[UIColor navigationbarColor] CGColor];
        _editBtn.layer.borderWidth = 1;
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_propertyTitleView addSubview:_editBtn];
        _propertyTitleView.alpha = 0;
    }
    return _propertyTitleView;
}

@end
