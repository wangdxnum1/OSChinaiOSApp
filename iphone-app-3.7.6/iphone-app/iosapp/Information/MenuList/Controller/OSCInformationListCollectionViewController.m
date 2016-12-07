//
//  OSCInformationListCollectionViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/10/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationListCollectionViewController.h"
#import "OSCMenuItem.h"
#import "OSCListItem.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCBanner.h"
#import "OSCModelHandler.h"

#import "SyntheticalTitleBarView.h"
#import "OSCInformationListCollectionViewCell.h"

#import "UINavigationController+Router.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "NSObject+Comment.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

@interface OSCInformationListCollectionViewController ()<OSCInformationListCollectionViewCellDelegate>
{
    BOOL _isTouchSliding;
    OSCMenuItem* _curMenuItem;
}

@property (nonatomic,strong) MBProgressHUD* HUD;
@property (nonatomic,strong) NSMutableArray* pageTokens;
//dataSources. this is mutableDictionary...
/** @{ 
        @"menuItem1_token" : OSCInformationListResultPostBackItem_1 ,
        @"menuItem2_token" : OSCInformationListResultPostBackItem_2
     }
 */
@property (nonatomic,strong) NSMutableDictionary<NSString* ,OSCInformationListResultPostBackItem* >* dataSources_dic;

@end

@implementation OSCInformationListCollectionViewController

#pragma mark - public property M
- (void)setMenuItem:(NSArray<OSCMenuItem *> *)menuItem{
    _menuItem = menuItem;
    
    if (_dataSources_dic == nil) {
        _dataSources_dic = [NSMutableDictionary dictionary];
        for (OSCMenuItem* curMenuItem in menuItem) {
            OSCInformationListResultPostBackItem* postBackItem = [OSCInformationListResultPostBackItem new];
            [self fillResultPostBackItem:postBackItem currentMenuItem:curMenuItem];
            [_dataSources_dic setObject:postBackItem forKey:curMenuItem.token];
        }
    }
    
    NSArray* allKeys = [_dataSources_dic allKeys];
    for (OSCMenuItem* curMenuItem in menuItem) {
        NSString* curMenuToken = curMenuItem.token;
        if (![allKeys containsObject:curMenuToken]) {
            OSCInformationListResultPostBackItem* postBackItem = [OSCInformationListResultPostBackItem new];
            [self fillResultPostBackItem:postBackItem currentMenuItem:curMenuItem];
            [_dataSources_dic setObject:postBackItem forKey:curMenuToken];
        }
    }
    [self.collectionView reloadData];
}

- (void)fillResultPostBackItem:(OSCInformationListResultPostBackItem* )postBackItem
               currentMenuItem:(OSCMenuItem* )curMenuItem
{
    NSString* cacheResource = [NSObject cacheResourceNameWithURL:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_INFORMATION_LIST] parameterDictionaryDesc:@{@"token" : curMenuItem.token}.description];
    NSDictionary* response = [NSObject responseObjectWithResource:cacheResource];
    NSArray* items = response[@"items"];
    NSString* pageToken = response[@"nextPageToken"];
    if (items && items.count > 0) {
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:items];
        for (OSCListItem* listItem in modelArray) {
            listItem.menuItem = curMenuItem;
            [listItem getLayoutInfo];
        }
        postBackItem.tableViewArr = modelArray;
        postBackItem.isFromCache = YES;
    }
    
    if (curMenuItem.banner.href) {
        NSString* bannerCacheResource = [NSObject cacheBannerResourceNameWithURL:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_BANNER] bannerCatalog:curMenuItem.banner.catalog];
        NSDictionary* bannerResponse = [NSObject responseObjectWithResource:bannerCacheResource];
        NSArray* items = bannerResponse[@"items"];
        if (items && items.count > 0) {
            NSArray *bannerModels = [NSArray osc_modelArrayWithClass:[OSCBanner class] json:items];
            postBackItem.bannerArr = bannerModels;
        }
    }
    
    if (pageToken && pageToken.length > 0) {
        postBackItem.pageToken = pageToken;
    }
    postBackItem.offestDistance = 0;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _isTouchSliding = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[OSCInformationListCollectionViewCell class] forCellWithReuseIdentifier:kInformationListCollectionViewCellIdentifier];
    self.collectionView.pagingEnabled = YES;
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    NSArray* allKeys = [_dataSources_dic allKeys];
    for (NSString* menuItem_token in allKeys) {
        if (![menuItem_token isEqualToString:_curMenuItem.token]) {
            OSCInformationListResultPostBackItem* resultItem = [_dataSources_dic objectForKey:menuItem_token];
            resultItem.bannerArr = nil;
            resultItem.tableViewArr = nil;
            resultItem.pageToken = nil;
            resultItem.offestDistance = 0;
            [_dataSources_dic setObject:resultItem forKey:menuItem_token];
        }
    }
}

#pragma mark --- layoutUI
- (void)layoutUI{
    
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuItem.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (!_isTouchSliding) {
        _curMenuItem = self.menuItem[indexPath.row];
        NSDictionary* curDic = [self getCurrentListDataSource];
        OSCInformationListCollectionViewCell* cell = [OSCInformationListCollectionViewCell returnReuseInformationListCollectionViewCell:collectionView identifier:kInformationListCollectionViewCellIdentifier indexPath:indexPath listModel:_curMenuItem];
        [cell configurationPostBackDictionary:curDic];
        cell.delegate = self;
        return cell;
//    }else{
//        return [UICollectionViewCell new];
//    }
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark - UIScrollView delegate 
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    _isTouchSliding = NO;
//}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    // custom setting code...
//    // handle touch tracking....
//    _isTouchSliding = YES;
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (decelerate) {
//        _isTouchSliding = NO;
//    }else{
//        _isTouchSliding = YES;
//    }
//}
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    _isTouchSliding = NO;
//}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    _isTouchSliding = NO;
    NSInteger index = scrollView.contentOffset.x / kScreenSize.width;
    if ([self.informationListCollectionDelegate respondsToSelector:@selector(ScrollViewDidEndWithIndex:)]) {
        [self.informationListCollectionDelegate ScrollViewDidEndWithIndex:index];
    }
}

#pragma mark - maintain the data source
- (NSDictionary<NSString* , OSCInformationListResultPostBackItem* >* )getCurrentListDataSource{
    NSString* curMenuToken = _curMenuItem.token;
    OSCInformationListResultPostBackItem* resultItem = [_dataSources_dic objectForKey:curMenuToken];
    NSDictionary* curResultDic = @{curMenuToken : resultItem};
    return curResultDic;
}

#pragma mark - OSCInformationListCollectionViewCellDelegate
- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                         updateDataSource:(NSDictionary<NSString* , OSCInformationListResultPostBackItem* >* )dataSourceDic
{
    NSString* needUpdateListToken = [[dataSourceDic allKeys] lastObject];
    OSCInformationListResultPostBackItem* postBackItem = [[dataSourceDic allValues] lastObject];
    [_dataSources_dic setValue:postBackItem forKey:needUpdateListToken];
}

- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                    didClickTableViewCell:(__kindof UITableViewCell* )tableViewCell
                       pushViewController:(UIViewController* )pushController
                                     href:(NSString *)urlString
{
    if (pushController) {
        [self.navigationController pushViewController:pushController animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:urlString] name:nil];
    }
}

- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                           didClickBanner:(__kindof UIView* )banner
                       pushViewController:(UIViewController* )pushController
                                     href:(NSString *)urlString
{
    if (pushController) {
        [self.navigationController pushViewController:pushController animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:urlString] name:nil];
    }
}

#pragma --mark 方法实现
- (void)beginRefreshWithIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    OSCInformationListCollectionViewCell *curCell = (OSCInformationListCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [curCell beginRefreshCurCell];
}

@end
