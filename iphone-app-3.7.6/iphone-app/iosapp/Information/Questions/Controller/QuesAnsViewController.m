//
//  QuesAnsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsViewController.h"

#import "Utils.h"
#import "QuesAnsTableViewCell.h"
#import "OSCPost.h"
#import "OSCQuestion.h"
#import "DetailsViewController.h"
#import "OSCAPI.h"
#import "QuesAnsDetailViewController.h"

#import <AFNetworking.h>
#import <MJRefresh.h>
#import "OSCModelHandler.h"

static NSString* const QuesAnsCellIdentifier = @"QuesAnsTableViewCell";


@interface QuesAnsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) UIButton* selectedBtn;
@property (nonatomic,strong) NSMutableArray* dataModels;
@property (nonatomic,strong) NSMutableArray* tokens;

@end

@implementation QuesAnsViewController

#pragma mark - life cycle

- (void)dawnAndNightMode:(NSNotificationCenter*)center
{
    [self setColorForSubViews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dawnAndNight" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _buttons = @[_askQuesButton, _shareButton, _synthButton, _jobButton, _officeButton];
    
    if(self.selectedBtn.tag == 0 ) {
        self.selectedBtn = _askQuesButton;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setColorForSubViews];

    [self settingSomething];
    [self setButtonBoradWidthAndColor:_askQuesButton isSelected:YES];
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];

}


#pragma mark - 设置颜色

- (void)setColorForSubViews
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    self.buttonViewLine.backgroundColor = [UIColor separatorColor];
    self.buttonView.backgroundColor = [UIColor newCellColor];
    
    _askQuesButton.backgroundColor = [UIColor titleBarColor];
    _shareButton.backgroundColor = [UIColor titleBarColor];
    _synthButton.backgroundColor = [UIColor titleBarColor];
    _jobButton.backgroundColor = [UIColor titleBarColor];
    _officeButton.backgroundColor = [UIColor titleBarColor];
}

#pragma mark - setting Something

-(void)settingSomething{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsTableViewCell" bundle:nil] forCellReuseIdentifier:QuesAnsCellIdentifier];
    
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
    
    NSString *url = [NSString stringWithFormat:@"%@question",OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager manager];
    [manger GET:url
     parameters:paraMutableDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([responseObject[@"code"]integerValue] == 1) {
                NSDictionary* result = responseObject[@"result"];
                NSArray *JsonItems = result[@"items"];
//                NSArray *models = [OSCQuestion mj_objectArrayWithKeyValuesArray:JsonItems];
                NSArray *models = [NSArray osc_modelArrayWithClass:[OSCQuestion class] json:JsonItems];
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
    
    QuesAnsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:QuesAnsCellIdentifier forIndexPath:indexPath];
    cell.viewModel = dataSource[indexPath.row];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /* 问答旧详情 */
    NSInteger currentIndex = self.selectedBtn.tag;
    NSArray* dataSource = self.dataModels[currentIndex];
    OSCQuestion* question = dataSource[indexPath.row];
    
    QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.questionID = question.Id;
    [self.navigationController pushViewController:detailVC animated:YES];
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
        _tokens = @[@"tokensPlaceholder",@"",@"",@"",@"",@""].mutableCopy;
    }
	return _tokens;
}

- (NSMutableArray *)dataModels {
	if(_dataModels == nil) {
        _dataModels = @[@[@"dataModelsPlaceholder"],@[],@[],@[],@[],@[]].mutableCopy;
	}
	return _dataModels;
}

- (NSArray *)buttons {
	if(_buttons == nil) {
		_buttons = @[_askQuesButton, _shareButton, _synthButton, _jobButton, _officeButton];
	}
    return _buttons;
}



@end
