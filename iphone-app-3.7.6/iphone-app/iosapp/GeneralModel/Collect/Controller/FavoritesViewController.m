//
//  FavoritesViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FavoritesViewController.h"

#import "Config.h"
#import "Utils.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"

#import "FavoritesCell.h"
#import "DetailsViewController.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "ActivityDetailViewController.h"
#import "TranslationViewController.h"
#import "NewBlogDetailController.h"
#import "OSCInformationDetailController.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>

static NSString * const kFavoriteCellID = @"FavoritesCell";

@interface FavoritesViewController () <networkingJsonDataDelegate>

@property (nonatomic, strong) NSMutableArray *dataModels;
@property (nonatomic, copy) NSString *pageToken;

@end


@implementation FavoritesViewController

- (instancetype)initWithFavoritesType:(FavoritesType)favoritesType
{
    self = [super init];
    if (self) {
        __weak FavoritesViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@favorites?catalog=%d", OSCAPI_V2_PREFIX, favoritesType];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 1? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getJsonDataWithParametersDic:@{} isRefresh:YES];
        [self.tableView reloadData];
    });
}

- (NSString *)title {
    return @"收藏";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"收藏";
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoritesCell" bundle:nil] forCellReuseIdentifier:kFavoriteCellID];
    
    self.tableView.estimatedRowHeight = 65;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - 获取数据
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh
{
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.pageToken length] > 0) {//下拉刷新请求
        [paraMutableDic setObject:self.pageToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  if([responseObject[@"code"] integerValue] == 1) {
                      NSDictionary *resultDic = responseObject[@"result"];
                      
                      NSArray *modelArray = [OSCFavorites mj_objectArrayWithKeyValuesArray:resultDic[@"items"]];
                      if (isRefresh) {//下拉得到的数据
                          [self.dataModels removeAllObjects];
                      }
                      [self.dataModels addObjectsFromArray:modelArray];
                      self.objects = self.dataModels;
                      self.pageToken = resultDic[@"nextPageToken"];
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          self.lastCell.status = modelArray.count < 1 ? LastCellStatusFinished : LastCellStatusMore;
                      });
                  } else if ([responseObject[@"code"] integerValue] == 404) {
                      self.lastCell.status = LastCellStatusFinished;
                      
                  } else {
                    
                      MBProgressHUD *HUD = [Utils createHUD];
                      HUD.mode = MBProgressHUDModeCustomView;
                      HUD.label.text = responseObject[@"message"];
                      
                      [HUD hideAnimated:YES afterDelay:1];
                      self.lastCell.status = LastCellStatusError;
                      
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      [self.tableView reloadData];
                  });
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = @"网络异常!";
                  
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

#pragma mark - fav
- (void)postFav:(long)favId favType:(FavoritesType)type
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@/favorite_reverse", OSCAPI_V2_PREFIX]
      parameters:@{
                   @"id"   : @(favId),
                   @"type" : @(type)
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue]== 1) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             } else {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"取消收藏失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }
             
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:1];
         }];

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoritesCell *favoriteCell = [tableView dequeueReusableCellWithIdentifier:kFavoriteCellID forIndexPath:indexPath];
    
    if (self.dataModels.count > 0) {
        OSCFavorites *favorite = self.dataModels[indexPath.row];

        favoriteCell.favorite = favorite;
    }
    
    favoriteCell.selectedBackgroundView = [[UIView alloc] initWithFrame:favoriteCell.frame];
    favoriteCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return favoriteCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

    if (self.dataModels.count > 0) {
        
        OSCFavorites *favorite = self.dataModels[indexPath.row];

        switch (favorite.type) {
            case FavoritesTypeSoftware: {        //软件详情
                SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:favorite.id];
                [detailsViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:detailsViewController animated:YES];
            }
                break;
            case FavoritesTypeQuestion: {           //问答详情
                QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
                detailVC.hidesBottomBarWhenPushed = YES;
                detailVC.questionID = favorite.id;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
                break;
            case FavoritesTypeBlog: {            //博客详情
                NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:favorite.id];
                [self.navigationController pushViewController:blogDetailVC animated:YES];
            }
                break;
            case FavoritesTypeTranslate: {
                //翻译
                TranslationViewController *translationVc = [TranslationViewController new];
                translationVc.translationId = favorite.id;
                [self.navigationController pushViewController:translationVc animated:YES];
            }
                break;
            case FavoritesTypeActivity: {
                //活动
                ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:favorite.id];
                [self.navigationController pushViewController:activityDetailCtl animated:YES];
            }
                break;
            case FavoritesTypeNews: {            //资讯详情
                OSCInformationDetailController* informationDeetailVC = [[OSCInformationDetailController alloc] initWithInformationID:favorite.id];
                [self.navigationController pushViewController:informationDeetailVC animated:YES];
            }
                break;
            default:
                [self.navigationController handleURL:[NSURL URLWithString:favorite.href] name:nil];
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        OSCFavorites *favorite = self.dataModels[indexPath.row];
        [self postFav:favorite.id favType:favorite.type];
        [_dataModels removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark --- lazy loading
- (NSMutableArray *)dataModels {
    if(_dataModels == nil) {
        _dataModels = [[NSMutableArray alloc] init];
    }
    return _dataModels;
}

@end
