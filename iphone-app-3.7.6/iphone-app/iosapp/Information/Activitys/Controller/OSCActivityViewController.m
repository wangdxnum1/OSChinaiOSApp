//
//  OSCActivityViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityViewController.h"
#import "OSCActivityTableViewCell.h"
#import "OSCActivities.h"
#import "OSCBanner.h"
#import "ActivityHeadView.h"
#import "ActivityDetailViewController.h"

#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "OSCModelHandler.h"

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 215

static NSString * const activityReuseIdentifier = @"OSCActivityTableViewCell";

@interface OSCActivityViewController ()<UITableViewDelegate,UITableViewDataSource, networkingJsonDataDelegate, ActivityHeadViewDelegate>

@property (nonatomic,strong) ActivityHeadView *bannerView;
@property (nonatomic, strong) NSMutableArray *activitys;
@property (nonatomic, strong) NSMutableArray *bannerModels;
@property (nonatomic,strong) NSString* nextToken;

@end

@implementation OSCActivityViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak OSCActivityViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@event",OSCAPI_V2_PREFIX];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 1? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        self.objClass = [OSCActivities class];
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.parametersDic = @{};
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
        
        _activitys = [NSMutableArray new];
        _bannerModels = [NSMutableArray new];
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bannerView = [[ActivityHeadView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 223)];
    self.bannerView.delegate = self;
    [self getBannerData];
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - method
#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary* result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
//        NSArray* modelArray = [OSCActivities mj_objectArrayWithKeyValuesArray:items];
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCActivities class] json:items];
        if (isRefresh) {//上拉得到的数据
            [self.activitys removeAllObjects];
        }
        [self.activitys addObjectsFromArray:modelArray];
    }
}

-(void)getBannerData{
    NSString* urlStr = [NSString stringWithFormat:@"%@banner",OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];    
    manger.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manger GET:urlStr
     parameters:@{@"catalog" : @3}
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSDictionary* resultDic = responseObject[@"result"];
            NSArray* responseArr = resultDic[@"items"];
            NSArray *bannerModels = [NSArray osc_modelArrayWithClass:[OSCBanner class] json:responseArr];
            self.bannerModels = bannerModels.mutableCopy;
            self.bannerView.banners = self.bannerModels.mutableCopy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark - layout UI

-(void)layoutUI{
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:activityReuseIdentifier];
    self.tableView.tableHeaderView = self.bannerView;
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)dawnAndNightMode
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark -- networking Delegate
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh{//yes 下拉 no 上拉
    
    if(isRefresh) {
        [self getBannerData];
    }
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic.copy
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if([responseObject[@"code"]integerValue] == 1) {
                      [self handleData:responseObject isRefresh:isRefresh];
                      NSDictionary* resultDic = responseObject[@"result"];
                      NSArray* items = resultDic[@"items"];
                      self.nextToken = resultDic[@"nextPageToken"];
                      
                      self.lastCell.status = items.count < 1 ? LastCellStatusFinished : LastCellStatusMore;
                      
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      if (!isRefresh) {
                          if (items.count > 0) {
                              [self.tableView.mj_footer endRefreshing];
                          } else {
                              [self.tableView.mj_footer endRefreshingWithNoMoreData];
                          }
                      }
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          [self.tableView reloadData];
                      });
                  }else{
                      //当下拉无更多数据返回code=0时
                      self.lastCell.status = LastCellStatusFinished;
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

#pragma mark - tableView datasource && delegate 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.activitys.count;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCActivityTableViewCell* cell = [OSCActivityTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:activityReuseIdentifier];
    
    cell.viewModel = self.activitys[indexPath.row];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCActivities *activity = _activitys[indexPath.row];
    
    //新活动详情页面
    ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:activity.id];
    activityDetailCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityDetailCtl animated:YES];
}


#pragma mark - 生成bannerItem View 并转换成最终的UIImage

-(UIImage* )mapBannerItem:(id)model{
    return [self imageWithUIView:nil];
}

#pragma mark - UIView 通过Graphics 转换成 UIImage

-(UIImage*)imageWithUIView:(UIView*) view{
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - ActivityHeadViewDelegate
- (void)clickScrollViewBanner:(NSInteger)bannerTag
{
    if (_bannerModels.count > 0) {
        OSCBanner *banner = _bannerModels[bannerTag];
        //新活动详情页面
        ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:banner.id];
        activityDetailCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activityDetailCtl animated:YES];
    }
    
}

@end
