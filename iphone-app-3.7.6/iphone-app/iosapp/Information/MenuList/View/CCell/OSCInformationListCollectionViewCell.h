//
//  OSCInformationListCollectionViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/10/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

#define kInformationListCollectionViewCellIdentifier @"OSCInformationListCollectionViewCell"

@class OSCInformationListCollectionViewCell,OSCBanner,OSCListItem,OSCMenuItem,OSCInformationListResultPostBackItem;
@protocol OSCInformationListCollectionViewCellDelegate <NSObject>

/** 因为collectionView的重用机制 将tableView请求到的最新数据源转发给controller维护 */
/** 
     updateDataSource = @{ @"OSCMenuItem.token" : OSCInformationListResultPostBackItem }
 
     OSCInformationListResultPostBackItem.bannerArr    =  @[bannerData] ;
     OSCInformationListResultPostBackItem.tableViewArr =  @[tableViewData] ;
     OSCInformationListResultPostBackItem.pageToken    =  @"curPageToken" ;
 */
- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                         updateDataSource:(NSDictionary<NSString* , OSCInformationListResultPostBackItem* >* )dataSourceDic;

- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                    didClickTableViewCell:(__kindof UITableViewCell* )tableViewCell
                       pushViewController:(UIViewController* )pushController
                                     href:(NSString* )urlString;

@optional
- (void)InformationListCollectionViewCell:(OSCInformationListCollectionViewCell* )curCell
                           didClickBanner:(__kindof UIView* )banner
                       pushViewController:(UIViewController* )pushController
                                     href:(NSString* )urlString;

@end

@interface OSCInformationListCollectionViewCell : UICollectionViewCell

+ (instancetype)returnReuseInformationListCollectionViewCell:(UICollectionView* )curCollectionView
                                                  identifier:(NSString* )identifierString
                                                   indexPath:(NSIndexPath* )indexPath
                                                   listModel:(OSCMenuItem* )model;;

- (void)configurationPostBackDictionary:(NSDictionary<NSString* , OSCInformationListResultPostBackItem* >* )resultItem;

@property (nonatomic,weak) id<OSCInformationListCollectionViewCellDelegate> delegate;

- (void)beginRefreshCurCell;

@end




@interface OSCInformationListResultPostBackItem : NSObject

@property (nonatomic,strong) NSArray<OSCBanner* >* bannerArr;

@property (nonatomic,strong) NSArray<OSCListItem* >* tableViewArr;

@property (nonatomic,strong) NSString* pageToken;

@property (nonatomic,assign) CGFloat offestDistance;

@property (nonatomic,assign) BOOL isFromCache;

+ (instancetype)createResultPostBackItemWith:(NSArray<OSCBanner* >* )bannerArr
                                tableViewArr:(NSArray<OSCListItem* >* )tableViewArr
                                   pageToken:(NSString* )pageToken
                              offestDistance:(CGFloat)offestDistance
                                 isFromCache:(BOOL)isFromCache;

@end

/** 
 using model replace
 
 #define dataSource_array_bannerKey      @"dataSource_bannerKey"
 #define dataSource_array_tableViewKey   @"dataSource_tableViewKey"
 #define dataSource_string_pageToken     @"pageToken"
 
@interface OSCInformationListPostBackDic : NSDictionary

- (void)updateBannerDataSource:(NSArray* )bannerArr;

- (void)updateTableViewDataSource:(NSArray* )tableViewArr;

- (void)updatePageToken:(NSString* )pageToken;

@end
*/






