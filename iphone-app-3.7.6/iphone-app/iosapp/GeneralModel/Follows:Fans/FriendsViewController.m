//
//  FriendsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FriendsViewController.h"
#import "OSCUserItem.h"
#import "PersonCell.h"
#import "OSCUserHomePageController.h"
#import "OSCNotice.h"
#import "Config.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>

static NSString * const kPersonCellID = @"PersonCell";

@interface FriendsViewController () <networkingJsonDataDelegate>

@property (nonatomic, assign) int64_t uid;


@property (nonatomic, assign) long userID;
@property (nonatomic, copy) NSString *lastUrlDefine;
@property (nonatomic, copy) NSString *nextPageToken;

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation FriendsViewController

- (instancetype)initUserId:(long)userId andRelation:(NSString *)lastUrlDefine
{
    self = [super init];
    if (self) {
        __weak FriendsViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@%@?id=%ld", OSCAPI_V2_PREFIX, lastUrlDefine, userId];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 1? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
        
        self.items = [NSMutableArray new];
    }
    return self;
}


#pragma mark - life cycle

- (void)viewDidAppear:(BOOL)animated
{
    OSCNotice *oldNotice = [Config getNotice];
    
    OSCNotice *notice = [OSCNotice new];
    notice.mention = oldNotice.mention;
    notice.letter = oldNotice.letter;
    notice.review = oldNotice.review;
    notice.fans = 0;
    notice.like = oldNotice.like;
    
    [Config saveNotice:notice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PersonCell class] forCellReuseIdentifier:kPersonCellID];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary *result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
        NSArray* modelArray = [OSCUserItem mj_objectArrayWithKeyValuesArray:items];
        
        if (isRefresh) {//上拉得到的数据
            [self.items removeAllObjects];
        }
        [self.items addObjectsFromArray:modelArray];
    }
}

#pragma mark - 获取具体用户博客
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh {
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.nextPageToken length] > 0) {
        [paraMutableDic setObject:self.nextPageToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject[@"code"] integerValue] == 1) {
                      
                      [self handleData:responseObject isRefresh:isRefresh];

                      NSDictionary *resultDic = responseObject[@"result"];
                      self.nextPageToken = resultDic[@"nextPageToken"];
                      NSArray* items = resultDic[@"items"];
                      
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
                  } else {
                      self.lastCell.status = LastCellStatusFinished;
                      [self.tableView.mj_header endRefreshing];
                      [self.tableView.mj_footer endRefreshing];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  //                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellID forIndexPath:indexPath];
    
    if (self.items.count > 0) {
        OSCUserItem *friend = self.items[indexPath.row];
        
        [cell.portrait loadPortrait:[NSURL URLWithString:friend.portrait]];
        cell.nameLabel.text = friend.name;
        cell.infoLabel.text = friend.more.expertise;
    }
    
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    OSCUserItem *friend = self.items[indexPath.row];
//    self.label.text = friend.name;
//    self.label.font = [UIFont systemFontOfSize:15];
//    CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
//    
//    self.label.text = friend.more.expertise;
//    self.label.font = [UIFont systemFontOfSize:12];
//    CGSize infoLabelSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
//    
//    return nameSize.height + infoLabelSize.height + 50;
    
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCUserItem *friend = self.items[indexPath.row];
    if (friend.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:friend.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.items.count > 0) {
        return self.items.count;
    }
    
    return 0;
}


@end
