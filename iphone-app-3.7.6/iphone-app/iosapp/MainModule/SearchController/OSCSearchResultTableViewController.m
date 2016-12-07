//
//  OSCSearchResultTableViewController.m
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSearchResultTableViewController.h"

#import "OSCAPI.h"
#import "OSCSearchItem.h"
#import "OSCModelHandler.h"
#import "OSCResultTableViewCell.h"
#import "OSCPushTypeControllerHelper.h"
#import "UINavigationController+Router.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UIView+Common.h"

#import <MJRefresh.h>
#import <AFNetworking.h>

@interface OSCSearchResultTableViewController () <UIScrollViewDelegate>

@property (nonatomic,assign)TableViewType tableViewType;
@property (nonatomic,strong)NSArray *requestType;
@property (nonatomic,strong)NSString *nextPageToken;
@property (nonatomic,strong)NSString *prevPageToken;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation OSCSearchResultTableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style withType:(TableViewType)type{
    self = [super initWithStyle:style];
    if(self){
        self.tableViewType = type;
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _requestType = @[@(3),@(1),@(6),@(2),@(11)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataWithisRefresh:NO];
    }];
    [self addContentView];
}

- (void)dealloc{
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addContentView{
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf getDataWithisRefresh:YES];
    }];
}

-(void)setKeyWord:(NSString *)keyWord{
    _keyWord = keyWord;
    _dataArray = [[NSMutableArray alloc] init];
    [self.tableView hideBlankPageView];
}

#pragma mark 数据处理
-(void)getDataWithisRefresh:(BOOL)isRefresh{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    if(_keyWord.length >= 5){
        manager.requestSerializer.timeoutInterval = 5.0f;
    }else{
        manager.requestSerializer.timeoutInterval = 10.0f;
    }
    if ([_resultDelegate respondsToSelector:@selector(resultVCBeginRequest)]) {
        [_resultDelegate resultVCBeginRequest];
    }
    if (isRefresh) {
        [self.tableView hideErrorPageView];
        NSString *urlString = [NSString stringWithFormat:@"%@/search?catalog=%@&content=%@&pageToken=",OSCAPI_V2_PREFIX,_requestType[_tableViewType],_keyWord];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                _nextPageToken = result[@"nextPageToken"];
                _prevPageToken = result[@"prevPageToken"];
                if (self.tableViewType == TableViewTypePerson) {
                    _dataArray = [[NSArray modelArrayWithClass:[OSCSearchPeopleItem class] json:result[@"items"]] mutableCopy];
                }else{
                    _dataArray = [[NSArray modelArrayWithClass:[OSCSearchItem class] json:result[@"items"]] mutableCopy];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_dataArray.count == 0){
                    [self.tableView showBlankPageView];
                    self.tableView.bounces = NO;
                }else{
                    [self.tableView hideBlankPageView];
                    self.tableView.bounces = YES;
                }
                [self.tableView reloadData];
                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                    [_resultDelegate resultVCCompleteRequest];
                }
            });
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"网络异常");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView showErrorPageView];
                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                    [_resultDelegate resultVCCompleteRequest];
                }
            });
        }];
    }else{
        NSString *urlString = [NSString stringWithFormat:@"%@/search?catalog=%@&content=%@&pageToken=%@",OSCAPI_V2_PREFIX,_requestType[_tableViewType],_keyWord,_nextPageToken];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                _nextPageToken = result[@"nextPageToken"];
                _prevPageToken = result[@"prevPageToken"];
                NSArray *items = [NSArray array];
                if(self.tableViewType == TableViewTypePerson){
                    items = [NSArray modelArrayWithClass:[OSCSearchPeopleItem class] json:result[@"items"]];
                }else{
                    items = [NSArray modelArrayWithClass:[OSCSearchItem class] json:result[@"items"]];
                }
                if (items.count != 0) {
                    for (id item in items) {
                        [_dataArray addObject:item];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self.tableView.mj_footer endRefreshing];
                        if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                            [_resultDelegate resultVCCompleteRequest];
                        }
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                        if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                            [_resultDelegate resultVCCompleteRequest];
                        }
                    });
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"网络异常");
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                    [_resultDelegate resultVCCompleteRequest];
                }
            });
        }];
    }
}

#pragma 方法实现
-(void)controllerChanged{
    if (_dataArray.count == 0 && self.keyWord != nil && self.tableView.blankPageView == nil) {
        [self.tableView reloadData];
        [self getDataWithisRefresh:YES];
    }
}

- (UITableViewCell *)createCellWithSearchResult:(id)result withCellID:(NSString *)cellID{
    if(self.tableViewType == TableViewTypePerson){
        OSCResultPersonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell){
            cell = [[[NSBundle mainBundle]loadNibNamed:@"OSCResultPersonCell" owner:nil options:nil] lastObject];
        }
        cell.model = result;
        return cell;
    }else{
        OSCSearchItem *model = result;
        OSCResultCoustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[OSCResultCoustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.title = model.title;
        if ([model.body isEqualToString:@""]) {
            cell.content = [NSString stringWithFormat:@"%@  发布于%@",model.title,model.pubDate];
        }else{
            cell.content = model.body;
        }
        return cell;
    }
}

#pragma mark - TableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [self createCellWithSearchResult:_dataArray[indexPath.row] withCellID:cellID];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma --mark TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [OSCPushTypeControllerHelper pushControllerWithSearchItem:_dataArray[indexPath.row]];
    if ([_resultDelegate respondsToSelector:@selector(resultClickCellWithContoller:withHref:)]) {
        if (self.tableViewType == TableViewTypePerson) {
            [_resultDelegate resultClickCellWithContoller:vc withHref:nil];
        }else{
            OSCSearchItem *model = _dataArray[indexPath.row];
            [_resultDelegate resultClickCellWithContoller:vc withHref:model.href];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.tableViewType == TableViewTypePerson) ? 95 : 83;
}

#pragma --mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([_resultDelegate respondsToSelector:@selector(resultTableViewDidScroll)]){
        [_resultDelegate resultTableViewDidScroll];
    }
}
@end
