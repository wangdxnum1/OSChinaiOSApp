//
//  OSCInformationListCollectionViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/10/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define BannerView_Simple_Height [UIScreen mainScreen].bounds.size.width * 39 / 125
#define BannerView_CustomActivity_Height 215

/**
#define InformationCell_Estimated_Height 132
#define BlogCell_Estimated_Height 105
#define ForumCell_Estimated_Height 105
#define ActivityCell_Estimated_Height 132
*/

#import "OSCInformationListCollectionViewCell.h"

#import "OSCMenuItem.h"
#import "OSCListItem.h"
#import "OSCBanner.h"
#import "OSCModelHandler.h"

#import "OSCPushTypeControllerHelper.h"
#import "NSObject+Comment.h"
#import "UIView+Common.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"

#import "OSCInformationTableViewCell.h" //information
#import "OSCBlogCell.h" //blogs
#import "OSCQuesAnsTableViewCell.h"//questions
#import "OSCActivityTableViewCell.h"//activity
#import "BannerScrollView.h"
#import "SDCycleScrollView.h"
#import "ActivityHeadView.h"
#import "UsualTableViewCell.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import <NSObject+YYAdd.h>

#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"


@interface OSCInformationListCollectionViewCell ()<UITableViewDelegate,UITableViewDataSource,ActivityHeadViewDelegate,BannerScrollViewDelegate>
{
    OSCMenuItem* _menuItem;
    NSString* _pageToken;
    CGFloat _offestDistance;
}
@property (nonatomic,strong) MBProgressHUD* HUD;
//optional_banner
@property (nonatomic,strong) BannerScrollView *bannerScrollView;
@property (nonatomic,strong) ActivityHeadView* activityBannerView;

@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) NSMutableArray<OSCListItem* >* dataSources;
@property (nonatomic,strong) NSMutableArray<OSCBanner* >* bannerDataSources;
@property (nonatomic,strong) NSMutableDictionary* updateToController_Dic;

@end

@implementation OSCInformationListCollectionViewCell
+ (instancetype)returnReuseInformationListCollectionViewCell:(UICollectionView *)curCollectionView
                                                  identifier:(NSString *)identifierString
                                                   indexPath:(NSIndexPath *)indexPath
                                                   listModel:(OSCMenuItem *)model
{
    OSCInformationListCollectionViewCell* cell = [curCollectionView dequeueReusableCellWithReuseIdentifier:identifierString forIndexPath:indexPath];
    cell->_menuItem = model;
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSources = [NSMutableArray array];
        _tableView = ({
            UITableView* tableView = [[UITableView alloc]initWithFrame:self.contentView.bounds];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.delegate = self;
            tableView.dataSource = self;
            
            [tableView registerClass:[OSCInformationTableViewCell class] forCellReuseIdentifier:InformationTableViewCell_IdentifierString];
            [tableView registerClass:[OSCBlogCell class] forCellReuseIdentifier:kNewHotBlogTableViewCellReuseIdentifier];
            [tableView registerClass:[OSCQuesAnsTableViewCell class] forCellReuseIdentifier:kQuesAnsTableViewCellReuseIdentifier];
            [tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:OSCActivityTableViewCell_IdentifierString];
            
            {
                __weak typeof(self) weakSelf = self;
                tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    [weakSelf commonRefresh];
                }];
                tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                    [weakSelf sendRequestGetListData:NO];
                }];
            }
            
            tableView;
        });
        [self.contentView addSubview:_tableView];
    }
    return self;
}

#pragma mark - public method M
- (void)beginRefreshCurCell{
    [self.tableView.mj_header beginRefreshing];
}
- (void)configurationPostBackDictionary:(NSDictionary<NSString* , OSCInformationListResultPostBackItem* >* )resultItem
{
    [self hideCustomPageView];
    self.tableView.mj_footer.state = MJRefreshStateIdle;

    if (self.dataSources.count > 0){
        _offestDistance = 0;
        [self.dataSources removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    switch (_menuItem.banner.catalog) {
        case OSCInformationListBannerTypeSimple:
        case OSCInformationListBannerTypeSimple_Blogs:{
            self.tableView.tableHeaderView = self.bannerScrollView;
            break;
        }
        case OSCInformationListBannerTypeCustom_Activity:{
            self.tableView.tableHeaderView = self.activityBannerView;
            break;
        }
        case OSCInformationListBannerTypeNone:
        default:{
            self.tableView.tableHeaderView = nil;
            break;
        }
    }

    OSCInformationListResultPostBackItem* resultItemModel = [[resultItem allValues] lastObject];
    _pageToken = resultItemModel.pageToken;
    if (resultItemModel.tableViewArr && resultItemModel.tableViewArr.count > 0) {
        _dataSources = resultItemModel.tableViewArr.count > 0 ? resultItemModel.tableViewArr.mutableCopy : nil;
        _bannerDataSources = resultItemModel.bannerArr.count > 0 ? resultItemModel.bannerArr.mutableCopy : nil;
        
        if (_bannerDataSources) {
            [self configurationBannerView];
        }else{
            self.tableView.tableHeaderView = nil;
        }
        [self.tableView reloadData];
        [self.tableView setContentOffset:(CGPoint){0,resultItemModel.offestDistance}];
        
        if (resultItemModel.isFromCache) { [self.tableView.mj_header beginRefreshing]; }
    }else{
        [self.tableView.mj_header beginRefreshing];
    }
}
- (void)configurationBannerView{
    switch (_menuItem.banner.catalog) {
        case OSCInformationListBannerTypeSimple:
        case OSCInformationListBannerTypeSimple_Blogs:{
            self.bannerScrollView.banners = [self.bannerDataSources copy];
            break;
        }
            
        case OSCInformationListBannerTypeCustom_Activity:{
            self.activityBannerView.banners = [self.bannerDataSources copy];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - refresh
- (void)commonRefresh{
    _offestDistance = 0;
    if (_menuItem.banner.href) {
        [self sendRequestGetBannerData];
    }
    [self sendRequestGetListData:YES];
}
#pragma mark - networking method
- (void)sendRequestGetBannerData{
    NSString* urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_BANNER];
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    manger.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manger GET:urlStr
     parameters:@{@"catalog" : @(_menuItem.banner.catalog)}
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* responseArr = resultDic[@"items"];
                NSArray *bannerModels = [NSArray osc_modelArrayWithClass:[OSCBanner class] json:responseArr];
                self.bannerDataSources = bannerModels.mutableCopy;
                if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:updateDataSource:)]) {
                    OSCInformationListResultPostBackItem* updateResultItem = [OSCInformationListResultPostBackItem createResultPostBackItemWith:self.bannerDataSources.copy tableViewArr:self.dataSources.copy pageToken:_pageToken offestDistance:_offestDistance isFromCache:NO];
                    NSDictionary* postBackDic = @{_menuItem.token : updateResultItem};
                    [_delegate InformationListCollectionViewCell:self updateDataSource:postBackDic];
                }
                
                /**banner cache buffer */
                if (responseArr && responseArr.count > 0) {
                    NSString* bannerResourceName = [NSObject cacheBannerResourceNameWithURL:urlStr bannerCatalog:_menuItem.banner.catalog];
                    [NSObject handleResponseObject:resultDic resource:bannerResourceName];
                }
                /***********************/
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configurationBannerView];
                    [self.tableView reloadData];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            _HUD = [Utils createHUD];
            _HUD.mode = MBProgressHUDModeCustomView;
            _HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
            [_HUD hideAnimated:YES afterDelay:1];
        }];
}
//YES:下拉获取最新数据  NO:上拉带token加载更多
- (void)sendRequestGetListData:(BOOL)isRefresh{
    
    if (_menuItem.isNeedLogin && [Config getOwnID] == 0) {
        [self showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_fail"] tipString:@"很遗憾,您必须登录才能查看此处内容"];
        return ;
    }else{
        [self hideCustomPageView];
    }
    
    NSString* strUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_INFORMATION_LIST];
    
    NSMutableDictionary* mutablePara = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [mutablePara setValue:_menuItem.token forKey:@"token"];
    if (!isRefresh && _pageToken.length > 0) {
        [mutablePara setValue:_pageToken forKey:@"pageToken"];
    }else{
        self.tableView.mj_footer.state = MJRefreshStateIdle;
    }
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    manger.requestSerializer.timeoutInterval = 20;
    [manger GET:strUrl
     parameters:mutablePara.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSDictionary* resultDic = responseObject[@"result"];
            NSArray* items = resultDic[@"items"];
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:items];
                for (OSCListItem* listItem in modelArray) {
                    listItem.menuItem = _menuItem;
                    [listItem getLayoutInfo];
                }
                
                if (modelArray && modelArray.count > 0 && isRefresh) {
                    [self.dataSources removeAllObjects];
                }
                [self.dataSources addObjectsFromArray:modelArray];
                NSString* pageToken = resultDic[@"nextPageToken"];
                if (pageToken && pageToken.length > 0) {
                    _pageToken = pageToken;
                }
            }
            if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:updateDataSource:)]) {
                OSCInformationListResultPostBackItem* updateResultItem = [OSCInformationListResultPostBackItem createResultPostBackItemWith:self.bannerDataSources.copy tableViewArr:self.dataSources.copy pageToken:_pageToken offestDistance:_offestDistance isFromCache:NO];
                NSDictionary* postBackDic = @{_menuItem.token : updateResultItem};
                [_delegate InformationListCollectionViewCell:self updateDataSource:postBackDic];
            }
            
            /**items cache buffer */
            if (items && items.count > 0 && isRefresh) {
                NSString* resourceName = [NSObject cacheResourceNameWithURL:strUrl parameterDictionaryDesc:[mutablePara.copy description]];
                [NSObject handleResponseObject:resultDic resource:resourceName];
            }
            /***********************/
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultDic == nil || items == nil || items.count < 1) {
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                        if (!self.dataSources || self.dataSources.count == 0) {
                            [self showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这里没找到数据呢"];
                        }
                    }else{
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                }else{
                    [self hideCustomPageView];
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                    }else{
                        [self.tableView.mj_footer endRefreshing];
                    }
                }
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            } else{
                [self.tableView.mj_footer endRefreshing];
            }
            if (!self.dataSources || self.dataSources.count == 0) {
                [self showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这里没找到数据呢"];
            }
        }];
}

#pragma mark - UITabelView delegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSources.count > 0) {
        return self.dataSources.count;
    }else{
        return 0;
    }
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSources.count > 0) {
        OSCListItem* listItem = self.dataSources[indexPath.row];
        UsualTableViewCell* curTableView = [self distributionListCurrentCellWithItem:listItem toTableView:tableView indexPaht:indexPath];
        [curTableView setValue:listItem forKey:@"listItem"];
        
        curTableView.selectedBackgroundView = [[UIView alloc] initWithFrame:curTableView.frame];
        curTableView.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return curTableView;
    }else{
        return [UITableViewCell new];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSources.count > 0) {
        OSCListItem* listItem = self.dataSources[indexPath.row];
        return [self distributionListCurrentCellHeightWithTableView:tableView listItem:listItem];
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UsualTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    OSCListItem* listItem = self.dataSources[indexPath.row];
//    [self holdCompleteReadInformationWithID:[NSString stringWithFormat:@"%ld",listItem.id]];
//    [cell setCompleteRead];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController* curVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:listItem.type detailContentID:listItem.id];
    if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:didClickTableViewCell:pushViewController:href:)]) {
        [_delegate InformationListCollectionViewCell:self didClickTableViewCell:[tableView cellForRowAtIndexPath:indexPath] pushViewController:curVC href:listItem.href];
    }
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _offestDistance = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:updateDataSource:)]) {
        OSCInformationListResultPostBackItem* updateResultItem = [OSCInformationListResultPostBackItem createResultPostBackItemWith:self.bannerDataSources.copy tableViewArr:self.dataSources.copy pageToken:_pageToken offestDistance:_offestDistance isFromCache:NO];
        NSDictionary* postBackDic = @{_menuItem.token : updateResultItem};
        [_delegate InformationListCollectionViewCell:self updateDataSource:postBackDic];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:updateDataSource:)]) {
        OSCInformationListResultPostBackItem* updateResultItem = [OSCInformationListResultPostBackItem createResultPostBackItemWith:self.bannerDataSources.copy tableViewArr:self.dataSources.copy pageToken:_pageToken offestDistance:_offestDistance isFromCache:NO];
        NSDictionary* postBackDic = @{_menuItem.token : updateResultItem};
        [_delegate InformationListCollectionViewCell:self updateDataSource:postBackDic];
    }
}

#pragma mark - distribute
/** tableViewCell distribute */
- (__kindof UITableViewCell* )distributionListCurrentCellWithItem:(OSCListItem* )listItem
                                                      toTableView:(UITableView* )tableView
                                                        indexPaht:(NSIndexPath* )indexPath
{
    switch (listItem.type) {
        case InformationTypeInfo:{
            OSCInformationTableViewCell *curCell = [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
            if (_menuItem.type == 6 && [_menuItem.subtype isEqualToString:@"1"]) {
                curCell.showCommentCount = NO;
            } else {
                curCell.showCommentCount = YES;
            }
            return curCell;
            break;
        }
        case InformationTypeBlog:{
            return [tableView dequeueReusableCellWithIdentifier:kNewHotBlogTableViewCellReuseIdentifier forIndexPath:indexPath];
            break;
        }
        case InformationTypeForum:{
            if ([_menuItem.token isEqualToString:@"d6112fa662bc4bf21084670a857fbd20"]) {
                 OSCInformationTableViewCell *curCell = [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
                curCell.showCommentCount = NO;
                
                return curCell;
            } else {
                return [tableView dequeueReusableCellWithIdentifier:kQuesAnsTableViewCellReuseIdentifier forIndexPath:indexPath];
            }
            
            break;
        }
        case InformationTypeActivity:{
            if ([_menuItem.token isEqualToString:@"d6112fa662bc4bf21084670a857fbd20"]) {
                OSCInformationTableViewCell *curCell = [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
                curCell.showCommentCount = NO;
                
                return curCell;
            } else {
                return [tableView dequeueReusableCellWithIdentifier:OSCActivityTableViewCell_IdentifierString forIndexPath:indexPath];
            }
            
            break;
        }
        default:{
            
            OSCInformationTableViewCell *curCell = [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
            if ((_menuItem.type == 1 && [_menuItem.subtype isEqualToString:@"1"]) ||
                (_menuItem.type == 4 && [_menuItem.subtype isEqualToString:@"1"]) ||
                (_menuItem.type == 7 && [_menuItem.subtype isEqualToString:@"1"])) {
                curCell.showCommentCount = NO;
            } else {
                curCell.showCommentCount = YES;
            }
            return curCell;
            break;
        }
    }
}

/** estimated height distribute*/
/**
- (CGFloat)distributionListCurrentCellEstimatedHeightWithTableView:(UITableView* )tableView
                                                          listItem:(OSCListItem* )listItem
{
    switch (listItem.type) {
        case InformationTypeInfo:
            return listItem.rowHeight;
            break;
            
        case InformationTypeBlog:
            return listItem.rowHeight;
            break;
            
        case InformationTypeForum:
            return listItem.rowHeight;
            break;
            
        case InformationTypeActivity:
            return ActivityCell_Estimated_Height;
            break;
            
        default:
            return listItem.rowHeight;;
            break;
    }
}
*/

/** height distribute */
- (CGFloat)distributionListCurrentCellHeightWithTableView:(UITableView* )tableView
                                                 listItem:(OSCListItem* )listItem
{
    switch (listItem.type) {
        case InformationTypeInfo:{
            return listItem.rowHeight;
            break;
        }
            
        case InformationTypeBlog:{
            return listItem.rowHeight;
            break;
        }
            
        case InformationTypeForum:{
            return listItem.rowHeight;
            break;
        }
            
        case InformationTypeActivity:{
            return listItem.rowHeight;
            break;
        }
            
        default:{
            return listItem.rowHeight;
        break;}
    }
}

#pragma mark - Banner Delegate
/// BannerScrollViewDelegate
- (void)clickedScrollViewBanners:(NSInteger)bannerTag{
    [self bannerPushHanle:bannerTag];
}
/// ActivityHeadViewDelegate
-(void)clickScrollViewBanner:(NSInteger)bannerTag{
    [self bannerPushHanle:bannerTag];
}
//push detail controller && Siri controller
- (void)bannerPushHanle:(NSInteger)bannerIndex{
    OSCBanner* banner = self.bannerDataSources[bannerIndex];
    UIViewController* pushVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:banner.type detailContentID:banner.id];
    
    if ([_delegate respondsToSelector:@selector(InformationListCollectionViewCell:didClickBanner:pushViewController:href:)]) {
        [_delegate InformationListCollectionViewCell:self didClickBanner:_menuItem.banner.catalog == OSCInformationListBannerTypeCustom_Activity ? self.activityBannerView : _menuItem.banner.catalog != OSCInformationListBannerTypeNone ? self.bannerScrollView : nil  pushViewController:pushVC href:banner.href];
    }
}

#pragma mark - lazy load
- (ActivityHeadView *)activityBannerView{
    if (!_activityBannerView) {
        _activityBannerView = [[ActivityHeadView alloc]initWithFrame:(CGRect){{0,0},{kScreen_Width,BannerView_CustomActivity_Height}}];
        _activityBannerView.delegate = self;
    }
    return _activityBannerView;
}
- (BannerScrollView *)bannerScrollView{
    if (!_bannerScrollView) {
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, BannerView_Simple_Height)];
        _bannerScrollView.delegate = self;
    }
    return _bannerScrollView;
}

#pragma --mark 存入与读取阅读信息
- (void)holdCompleteReadInformationWithID:(NSString *)information{
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] valueForKey:@"CompleteRead"] mutableCopy];
    if (!array) {
        array = [[NSMutableArray alloc] init];
    }
    if (![array containsObject:information]) {
        [array addObject:information];
    }
    NSArray *completeRead = [array copy];
    [[NSUserDefaults standardUserDefaults] setValue:completeRead forKey:@"CompleteRead"];
}

- (BOOL)isExistOfCompleteReadWithID:(NSString *)information{
    NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"CompleteRead"];
    if (array) {
        return [array containsObject:information];
    }
    return NO;
}

@end



@implementation OSCInformationListResultPostBackItem

+ (instancetype)createResultPostBackItemWith:(NSArray<OSCBanner *> *)bannerArr
                                tableViewArr:(NSArray<OSCListItem *> *)tableViewArr
                                   pageToken:(NSString *)pageToken
                              offestDistance:(CGFloat)offestDistance
                                 isFromCache:(BOOL)isFromCache
{
    OSCInformationListResultPostBackItem* resultItem = [OSCInformationListResultPostBackItem new];
    resultItem.bannerArr = bannerArr;
    resultItem.tableViewArr = tableViewArr;
    resultItem.pageToken = pageToken;
    resultItem.offestDistance = offestDistance;
    resultItem.isFromCache = isFromCache;
    return resultItem;
}

@end


/**
@implementation OSCInformationListPostBackDic{
    NSMutableDictionary* _mutableDic;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _mutableDic = [NSMutableDictionary dictionaryWithCapacity:3];
        [_mutableDic setValue:@[] forKey:dataSource_array_bannerKey];
        [_mutableDic setValue:@[] forKey:dataSource_array_tableViewKey];
        [_mutableDic setValue:@"" forKey:dataSource_string_pageToken];
        self = _mutableDic.copy;
    }
    return self;
}

- (void)updateBannerDataSource:(NSArray *)bannerArr{
    [_mutableDic setValue:bannerArr forKey:dataSource_array_bannerKey];
}
- (void)updateTableViewDataSource:(NSArray *)tableViewArr{
    [_mutableDic setValue:tableViewArr forKey:dataSource_array_tableViewKey];
}
- (void)updatePageToken:(NSString *)pageToken{
    [_mutableDic setValue:pageToken forKey:dataSource_string_pageToken];
}

@end
*/
