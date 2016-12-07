//
//  MyQustionViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "MyQustionViewController.h"
#import "OSCAPI.h"
#import "OSCQuestion.h"
#import "QuesAnsTableViewCell.h"
#import "QuesAnsDetailViewController.h"
#import "Utils.h"
#import "OSCModelHandler.h"

#import <MBProgressHUD.h>
#import <MJRefresh.h>

static NSString* const reuseQuesAnsTableViewCellReuseIdentifier = @"QuesAnsTableViewCell";
@interface MyQustionViewController ()

@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, strong) NSString *nextToken;
@property (nonatomic, strong) NSMutableArray *quetions;

@end

@implementation MyQustionViewController

- (instancetype)initWithAuthorId:(NSInteger)authorId
{
    self = [super init];
    if (self) {
        self.authorId = authorId;
        
        _quetions = [NSMutableArray new];
        _nextToken = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"问答";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsTableViewCell" bundle:nil] forCellReuseIdentifier:reuseQuesAnsTableViewCellReuseIdentifier];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getMyQustionData:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMyQustionData:NO];
    }];

    [self.tableView.mj_header beginRefreshing];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - get datasoure
- (void)getMyQustionData:(BOOL)isReFresh
{
    MBProgressHUD *HUD = [MBProgressHUD new];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if (isReFresh) {
        [_quetions removeAllObjects];
        _nextToken = @"";
    }
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];

    [manger GET:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_QUESTION]
     parameters:@{
                  @"authorId"  : @(_authorId),
                  @"catalog"   : @(0),
                  @"pageToken" : _nextToken
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* items = resultDic[@"items"];
                NSArray *models = [NSArray osc_modelArrayWithClass:[OSCQuestion class] json:items];
                
                [self.quetions addObjectsFromArray:models];
                _nextToken = resultDic[@"nextPageToken"];
                
            } else{
                HUD.label.text = @"未知错误";
                [HUD hideAnimated:YES afterDelay:1];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (isReFresh) {
                    [self.tableView.mj_header endRefreshing];
                } else {
                    [self.tableView.mj_footer endRefreshing];
                }
                [HUD hideAnimated:YES afterDelay:1];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
    
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isReFresh) {
                    [self.tableView.mj_header endRefreshing];
                } else {
                    [self.tableView.mj_footer endRefreshing];
                }
                HUD.label.text = @"网络异常，操作失败";
                [HUD hideAnimated:YES afterDelay:0.3];
            });
        }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_quetions.count > 0) {
        return _quetions.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuesAnsTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:reuseQuesAnsTableViewCellReuseIdentifier forIndexPath:indexPath];
    if (_quetions.count > 0) {
        OSCQuestion* questionItem = _quetions[indexPath.row];
        questionCell.viewModel = questionItem;
    }
    
    questionCell.selectedBackgroundView = [[UIView alloc] initWithFrame:questionCell.frame];
    questionCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    

    return questionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_quetions.count > 0) {
        OSCQuestion *question = _quetions[indexPath.row];
        QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
        detailVC.hidesBottomBarWhenPushed = YES;
        detailVC.questionID = question.Id;
        [self.navigationController pushViewController:detailVC animated:YES];
    }

}

@end
