//
//  NewBlogsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/7/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewBlogsViewController.h"

#import "Utils.h"
#import "NewHotBlogTableViewCell.h"
#import "OSCPost.h"
#import "OSCNewHotBlog.h"
#import "OSCQuestion.h"
#import "DetailsViewController.h"
#import "OSCAPI.h"
#import "NewBlogDetailController.h"
#import "OSCInformationDetailController.h"

#import <AFNetworking.h>
#import <MJRefresh.h>

#import "OSCModelHandler.h"

static NSString* const ReuseIdentifier = @"NewHotBlogTableViewCell";

@interface NewBlogsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic,strong) UIButton* selectedBtn;

@property (nonatomic,strong) NSMutableArray* dataModels;
@property (nonatomic,strong) NSMutableArray* tokens;

@end

@implementation NewBlogsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _buttons = @[_normalButton, _hotButton, _recommendButton];
    
    if(self.selectedBtn.tag == 0 ) {
        self.selectedBtn = _recommendButton;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setColorForSubViews];
    
    [self settingSomething];
    [self setButtonBoradWidthAndColor:_recommendButton isSelected:YES];
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - 设置颜色

- (void)setColorForSubViews
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    
    _recommendButton.backgroundColor = [UIColor titleBarColor];
    _hotButton.backgroundColor = [UIColor titleBarColor];
    _normalButton.backgroundColor = [UIColor titleBarColor];
}

#pragma mark - setting Something

-(void)settingSomething{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewHotBlogTableViewCell" bundle:nil] forCellReuseIdentifier:ReuseIdentifier];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self sendNetworkingRequestWithRefresh:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self sendNetworkingRequestWithRefresh:NO];
    }];
}

#pragma mark - NetWorking

-(void)sendNetworkingRequestWithRefresh:(BOOL)isRefresh{
	
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    
    NSInteger index = self.selectedBtn.tag;
    
    [paraMutableDic setObject:@(index) forKey:@"catalog"];
    if (isRefresh == NO) {//下拉刷新请求
        [paraMutableDic setObject:self.tokens[index] forKey:@"pageToken"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@blog",OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager manager];
    [manger GET:url
     parameters:paraMutableDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSDictionary* result = responseObject[@"result"];
            NSArray* JsonItems = result[@"items"];
            NSArray *models = [NSArray osc_modelArrayWithClass:[OSCNewHotBlog class] json:JsonItems];
            self.tokens[index] = result[@"nextPageToken"];
            if (isRefresh) {
                self.dataModels[index] = models;
            }else {
                [self.dataModels[index] addObjectsFromArray:models];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                } else {
					[self.tableView.mj_footer endRefreshing];
                }
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            NSLog(@"%@",error);
        }];
}



#pragma mark - tableView delegate && datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger currentIndex = self.selectedBtn.tag;
    NSArray* dataSource = self.dataModels[currentIndex];
    return dataSource.count;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger currentIndex = self.selectedBtn.tag;
    NSArray* dataSource = self.dataModels[currentIndex];
    
    NewHotBlogTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.titleLabel.textColor = [UIColor newTitleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    cell.blog = dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger currentIndex = self.selectedBtn.tag;
    NSArray* dataSource = self.dataModels[currentIndex];
    OSCNewHotBlog* blog = dataSource[indexPath.row];
    NewBlogDetailController* newsBlogDetailVc = [[NewBlogDetailController alloc] initWithBlogId:blog.id];
    newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
}

#pragma mark - 改变selected Btn && 切换数据源 && 选择性发送请求

- (IBAction)clickSubTitle:(UIButton *)sender {
    
    self.selectedBtn = sender;
    
    NSInteger tagNumber = sender.tag;
    NSArray* dataSource = self.dataModels[tagNumber];
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == tagNumber-1) {
            [self setButtonBoradWidthAndColor:obj isSelected:YES];
        } else {
            [self setButtonBoradWidthAndColor:obj isSelected:NO];
        }
    }];
    
    if (dataSource.count == 0) {
        [self.tableView.mj_header beginRefreshing];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 按钮设置边框、颜色
- (void)setButtonBoradWidthAndColor:(UIButton *)button isSelected:(BOOL)isSelected
{
    if (isSelected) {
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor newSectionButtonSelectedColor].CGColor;
        [button setTitleColor:[UIColor newSectionButtonSelectedColor] forState:UIControlStateNormal];
    } else {
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor colorWithHex:0xF6F6F6].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x6A6A6A] forState:UIControlStateNormal];
    }
    
}

#pragma mark - lazy loading

- (NSMutableArray *)tokens {
    if(_tokens == nil) {
        _tokens = @[@"tokensPlaceholder",@"",@"",@""].mutableCopy;
    }
    return _tokens;
}

- (NSMutableArray *)dataModels {
    if(_dataModels == nil) {
        _dataModels = @[@[@"dataModelsPlaceholder"],@[],@[],@[]].mutableCopy;
    }
    return _dataModels;
}

- (NSArray *)buttons {
    if(_buttons == nil) {
        _buttons = @[_normalButton, _hotButton, _recommendButton];
    }
    return _buttons;
}

@end
