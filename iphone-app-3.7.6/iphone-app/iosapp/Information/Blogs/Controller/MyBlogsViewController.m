//
//  MyBlogsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/7/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "MyBlogsViewController.h"

#import "NewHotBlogTableViewCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "DetailsViewController.h"
#import "OSCNewHotBlog.h"
#import <MBProgressHUD.h>
#import <MJExtension.h>
#import "NewBlogDetailController.h"

static NSString *reuseIdentifier = @"NewHotBlogTableViewCell";

@interface MyBlogsViewController () <networkingJsonDataDelegate>

@property (nonatomic, strong) NSMutableArray *blogObjects;
@property (nonatomic,strong) NSString* nextToken;

@end

@implementation MyBlogsViewController

- (instancetype)initWithUserID:(NSInteger)userID
{
    self = [super init];
    if (self) {
        __weak MyBlogsViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@blog?userId=%ld",OSCAPI_V2_PREFIX, (long)userID];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _blogObjects = [NSMutableArray new];
    
    self.navigationItem.title = @"我的博客";
    
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NewHotBlogTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - method
#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary *result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
        NSArray* modelArray = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:items];
        
        self.nextToken = result[@"nextPageToken"];
        if (isRefresh) {//上拉得到的数据
            [self.blogObjects removeAllObjects];
        }
        [self.blogObjects addObjectsFromArray:modelArray];
    }
}

#pragma mark - 获取具体用户博客
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh {
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject[@"code"]integerValue] == 1) {
                      [self handleData:responseObject isRefresh:isRefresh];
                      
                      NSDictionary *resultDic = responseObject[@"result"];
                      NSArray* items = resultDic[@"items"];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          self.lastCell.status = items.count < 20 ? LastCellStatusFinished : LastCellStatusMore;
                          if (self.tableView.mj_header.isRefreshing) {
                              [self.tableView.mj_header endRefreshing];
                          }
                          [self.tableView reloadData];
                      });
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                  
                  [HUD hideAnimated:YES afterDelay:1];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      self.lastCell.status = LastCellStatusError;
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      [self.tableView reloadData];
                  });
              }
     ];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_blogObjects.count > 0) {
        return _blogObjects.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewHotBlogTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.titleLabel.textColor = [UIColor newTitleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    if (self.blogObjects.count > 0) {
        OSCNewHotBlog *blog = self.blogObjects[indexPath.row];
        
        cell.blog = blog;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    OSCNewHotBlog *blog;
    
    if (self.blogObjects.count > 0) {
        blog = self.blogObjects[indexPath.row];
    }
    NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:blog.id];
    blogDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:blogDetailVC animated:YES];
}

@end
