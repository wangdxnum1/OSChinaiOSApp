//
//  OSCInformationListController.m
//  iosapp
//
//  Created by Graphic-one on 16/10/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define BannerView_Simple_Height [UIScreen mainScreen].bounds.size.width * 39 / 125
#define BannerView_CustomActivity_Height 215

#import "OSCInformationListController.h"
#import "SDCycleScrollView.h"
#import "ActivityHeadView.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "OSCBanner.h"
#import "OSCMenuItem.h"
#import "OSCListItem.h"
#import "OSCModelHandler.h"
#import "OSCPushTypeControllerHelper.h"

//old cells
#import "InformationTableViewCell.h"
#import "NewHotBlogTableViewCell.h"
#import "QuesAnsTableViewCell.h"
#import "OSCActivityTableViewCell.h"

#import <MBProgressHUD.h>
/**
#import "OSCListNomalCell.h"
#import "OSCListDivideCell.h"
#import "OSCListAdCell.h"
 */

#import <MJRefresh.h>

@interface OSCInformationListController () <UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate,ActivityHeadViewDelegate>
{
    OSCInformationListBannerType _listType;
    NSString* _listToken;
}
@property (nonatomic,strong) NSArray<OSCBanner* >* bannerModels;
@property (nonatomic,strong) OSCMenuItem* model;//sub_menu Model
@property (nonatomic,strong) NSMutableArray* dataSourceArr;//list dataSource

@property (nonatomic,strong) NSString* pageToken;

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) MBProgressHUD* HUD;
//optional_banner
@property (nonatomic,strong) SDCycleScrollView *simpleBannerView;
@property (nonatomic,strong) ActivityHeadView* activityBannerView;

@end

@implementation OSCInformationListController

+ (instancetype)InformationListWithListModel:(OSCMenuItem* )model{
    OSCInformationListController* curVC = [OSCInformationListController new];
    curVC.model = model;
    curVC->_listType = model.banner.catalog;
    curVC->_listToken = model.token;
    return curVC;
}



#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layoutUI
- (void)layoutUI{
    self.tableView = ({
        UITableView* tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
/**
        [tableView registerNib:[UINib nibWithNibName:@"OSCListNomalCell" bundle:nil] forCellReuseIdentifier:kOSCListNomalCellReuseIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"OSCListDivideCell" bundle:nil] forCellReuseIdentifier:kOSCListDivideCellReuseIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"OSCListAdCell" bundle:nil] forCellReuseIdentifier:kOSCListAdCellReuseIdentifier];
 */
        [self.tableView registerNib:[UINib nibWithNibName:@"InformationTableViewCell" bundle:nil] forCellReuseIdentifier:InformationTableViewCell_IdentifierString];
        [self.tableView registerNib:[UINib nibWithNibName:@"NewHotBlogTableViewCell" bundle:nil] forCellReuseIdentifier:kNewHotBlogTableViewCellReuseIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsTableViewCell" bundle:nil] forCellReuseIdentifier:kQuesAnsTableViewCellReuseIdentifier];
        [self.tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:OSCActivityTableViewCell_IdentifierString];

        {
            __weak typeof(self) weakSelf = self;
            tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
                [weakSelf commonRefresh];
            }];
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf sendRequestGetListData:NO];
            }];
        }

        if (_model.banner) {
            if (_listType == OSCInformationListBannerTypeSimple) {
                tableView.tableHeaderView = self.simpleBannerView;
            }else if(_listType == OSCInformationListBannerTypeSimple_Blogs){
                tableView.tableHeaderView = self.simpleBannerView;
            }else if (_listType == OSCInformationListBannerTypeCustom_Activity){
                tableView.tableHeaderView = self.activityBannerView;
            }else{
                tableView.tableHeaderView = nil;
            }
        }
        
        [self.view addSubview:tableView];
        tableView;
    });
}

#pragma mark - NetWorking 
- (void)commonRefresh{
    if (_model.banner.href) {
        [self sendRequestGetBannerData];
    }
    [self sendRequestGetListData:YES];
}
- (void)configurationBannerView{
    switch (_model.banner.catalog) {
        case OSCInformationListBannerTypeSimple:
        case OSCInformationListBannerTypeSimple_Blogs:{
            NSMutableArray<NSString* >* titleArr,* imageArr ;
            for (OSCBanner* banner in self.bannerModels) {
                [titleArr addObject:banner.name];
                [imageArr addObject:banner.img];
            }
            self.simpleBannerView.imageURLStringsGroup = imageArr.copy;
            self.simpleBannerView.titlesGroup = titleArr.copy;
            break;
        }
            
        case OSCInformationListBannerTypeCustom_Activity:{
            self.activityBannerView.banners = [self.bannerModels copy];
            break;
        }
            
        default:
            break;
    }
}
- (void)sendRequestGetBannerData{
    NSString* urlStr = [NSString stringWithFormat:@"%@banner",OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    manger.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manger GET:urlStr
     parameters:@{@"catalog" : @(_model.banner.catalog)}
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* responseArr = resultDic[@"items"];
                NSArray *bannerModels = [NSArray osc_modelArrayWithClass:[OSCBanner class] json:responseArr];
                self.bannerModels = bannerModels.mutableCopy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configurationBannerView];
                    [self.tableView reloadData];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}
//YES:下拉获取最新数据  NO:上拉带token加载更多
- (void)sendRequestGetListData:(BOOL)isRefresh{
    NSMutableDictionary* mutablePara = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [mutablePara setValue:_listToken forKey:@"token"];
    if (!isRefresh && self.pageToken.length > 0) {
        [mutablePara setValue:self.pageToken forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_INFORMATION_LIST]
     parameters:mutablePara.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
#pragma TODO :: networking handle

            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                } else{
                    [self.tableView.mj_footer endRefreshing];
                }
                [self.tableView reloadData];
            });
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            _HUD = [Utils createHUD];
            _HUD.mode = MBProgressHUDModeCustomView;
            _HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
            [_HUD hideAnimated:YES afterDelay:1];
            
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            } else{
                [self.tableView.mj_footer endRefreshing];
            }
        }];
}


#pragma mark - UITabelView delegate && dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCListItem* listItem = self.dataSourceArr[indexPath.row];
    UITableViewCell* curTableView = [self distributionListCurrentCellWithItem:listItem toTableView:tableView indexPaht:indexPath];
    [curTableView setValue:listItem forKey:@"listItem"];
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCListItem* listItem = self.dataSourceArr[indexPath.row];
    UIViewController* curVC = [OSCPushTypeControllerHelper pushControllerWithListItem:listItem];
    if (curVC) {
        [self.navigationController pushViewController:curVC animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:listItem.href] name:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCListItem* listItem = self.dataSourceArr[indexPath.row];
    return [self distributionListCurrentCellHeightWithCurTableViewCell:[tableView cellForRowAtIndexPath:indexPath] toTableView:tableView listItem:listItem];
}

#pragma mark - tableViewCell 分发
- (__kindof UITableViewCell* )distributionListCurrentCellWithItem:(OSCListItem* )listItem
                                                      toTableView:(UITableView* )tableView
                                                        indexPaht:(NSIndexPath* )indexPath
{
    switch (listItem.type) {
        case InformationTypeInfo:{
            return [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
            break;
        }
        case InformationTypeBlog:{
            return [tableView dequeueReusableCellWithIdentifier:kNewHotBlogTableViewCellReuseIdentifier forIndexPath:indexPath];
            break;
        }
        case InformationTypeForum:{
           return [tableView dequeueReusableCellWithIdentifier:kQuesAnsTableViewCellReuseIdentifier forIndexPath:indexPath];
            break;
        }
        case InformationTypeActivity:{
            return [tableView dequeueReusableCellWithIdentifier:OSCActivityTableViewCell_IdentifierString forIndexPath:indexPath];
            break;
        }
        default:{
           return [tableView dequeueReusableCellWithIdentifier:InformationTableViewCell_IdentifierString forIndexPath:indexPath];
            break;
        }
    }
}
- (CGFloat)distributionListCurrentCellHeightWithCurTableViewCell:(__kindof UITableViewCell* )curTableViewCell
                                                     toTableView:(UITableView* )tableView
                                                        listItem:(OSCListItem* )listItem
{
    return 0;
//    Class cls = [curTableViewCell class];
//    if ([[cls className] isEqualToString:[[NewHotBlogTableViewCell class] className]]) {
//        return [tableView fd_heightForCellWithIdentifier:kNewHotBlogTableViewCellReuseIdentifier configuration:^(id cell) {
//            [curTableViewCell setValue:listItem forKey:@"listItem"];
//        }];
//    }
//    
//    else if ([[cls className] isEqualToString:[[QuesAnsTableViewCell class] className]]){
//        return [tableView fd_heightForCellWithIdentifier:kQuesAnsTableViewCellReuseIdentifier configuration:^(id cell) {
//            [curTableViewCell setValue:listItem forKey:@"listItem"];
//        }];
//    }
//    
//    else if ([[cls className] isEqualToString:[[OSCActivityTableViewCell class] className]]){
//        return [tableView fd_heightForCellWithIdentifier:OSCActivityTableViewCell_IdentifierString configuration:^(id cell) {
//            [curTableViewCell setValue:listItem forKey:@"listItem"];
//        }];
//    }
//    
//    else{
//        return [tableView fd_heightForCellWithIdentifier:InformationTableViewCell_IdentifierString configuration:^(id cell) {
//            [curTableViewCell setValue:listItem forKey:@"listItem"];
//        }];
//    }
}

#pragma mark - Banner Delegate
/// SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [self bannerPushHanle:index];
}
/// ActivityHeadViewDelegate
-(void)clickScrollViewBanner:(NSInteger)bannerTag{
    [self bannerPushHanle:bannerTag];
}
//push detail controller && Siri controller
- (void)bannerPushHanle:(NSInteger)bannerIndex{
    OSCBanner* banner = self.bannerModels[bannerIndex];
    UIViewController* pushVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:banner.type detailContentID:banner.id];
    if (pushVC) {
        [self.navigationController pushViewController:pushVC animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:banner.href] name:nil];
    }
}

#pragma mark - lazy load
- (SDCycleScrollView *)simpleBannerView{
    if (!_simpleBannerView) {
        _simpleBannerView = [SDCycleScrollView cycleScrollViewWithFrame:(CGRect){{0,0},{kScreen_Width,BannerView_Simple_Height}} delegate:self placeholderImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]]];
        _simpleBannerView.showPageControl = YES;
        _simpleBannerView.hidesForSinglePage = YES;
    }
    return _simpleBannerView;
}
- (ActivityHeadView *)activityBannerView{
    if (!_activityBannerView) {
        _activityBannerView = [[ActivityHeadView alloc]initWithFrame:(CGRect){{0,0},{kScreen_Width,BannerView_CustomActivity_Height}}];
        _activityBannerView.delegate = self;
    }
    return _activityBannerView;
}


@end
