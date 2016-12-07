//
//  OSCTweetRecommendCollectionController.m
//  iosapp
//
//  Created by 王恒 on 16/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetRecommendCollectionController.h"
#import "OSCTweetRecommendCollectionCell.h"

#import "OSCRecommendTopicsController.h"
#import "OSCAPI.h"
#import "OSCModelHandler.h"
#import "OSCTweetItem.h"
#import "UIView+Common.h"
#import <MJRefresh.h>
#import "AFHTTPRequestOperationManager+Util.h"

#define kUsualSpacing 20

@interface OSCTweetRecommendCollectionController ()

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *nextPageToken;
@property (nonatomic,strong) NSString *prevPageToken;

@end

@implementation OSCTweetRecommendCollectionController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = kUsualSpacing;
    layout.minimumInteritemSpacing = kUsualSpacing;
    layout.sectionInset = UIEdgeInsetsMake(kUsualSpacing, kUsualSpacing, kUsualSpacing, kUsualSpacing);
    self = [super initWithCollectionViewLayout:layout];
    if(self){
        self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.collectionView.alwaysBounceVertical = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_dataArray.count == 0){
        [self getDataWithRefresh:YES];
    }
    [self.collectionView registerClass:[OSCTweetRecommendCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataWithRefresh:YES];
    }];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataWithRefresh:NO];
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView configReloadAction:^{
        [weakSelf getDataWithRefresh:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDataWithRefresh:(BOOL)isRefresh{
    [self.collectionView hideErrorPageView];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    manager.requestSerializer.timeoutInterval = 5;
    if (isRefresh) {
        [manager GET:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,@"tweet_topics"] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                _nextPageToken = result[@"nextPageToken"];
                _prevPageToken = result[@"prevPageToken"];
                _dataArray = [[NSArray osc_modelArrayWithClass:[OSCTweetTopicItem class] json:result[@"items"]] mutableCopy];
                if (_dataArray.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView.mj_header endRefreshing];
                        [self.collectionView showBlankPageView];
                        [self.collectionView reloadData];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView hideBlankPageView];
                        [self.collectionView reloadData];
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.mj_header endRefreshing];
            });
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            _dataArray = [[NSMutableArray alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.mj_header endRefreshing];
                [self.collectionView reloadData];
                [self.collectionView showErrorPageView];
            });
        }];
    }else{
        [manager GET:[NSString stringWithFormat:@"%@%@?pageToken=%@",OSCAPI_V2_PREFIX,@"tweet_topics",_nextPageToken] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                _nextPageToken = result[@"nextPageToken"];
                _prevPageToken = result[@"prevPageToken"];
                NSArray *resultArr = [NSArray osc_modelArrayWithClass:[OSCTweetTopicItem class] json:result[@"items"]];
                if (resultArr.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    });
                }else{
                    for(OSCTweetTopicItem *result in resultArr){
                        [_dataArray addObject:result];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView.mj_footer endRefreshing];
                        [self.collectionView reloadData];
                    });
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            _dataArray = [[NSMutableArray alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.mj_footer endRefreshing];
                [self.collectionView reloadData];
                [self.collectionView showErrorPageView];
            });
        }];
    }
}

#pragma --mark UICollectionLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 48 + 56 * [_dataArray[indexPath.row] count] + 16 + 40;
    return CGSizeMake(kScreenSize.width - 2 * kUsualSpacing, height);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSCTweetRecommendCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    OSCTweetTopicItem *model = _dataArray[indexPath.row];
    cell.contentArray = model.items;
    cell.peopleCount = model.joinCount;
    cell.title = model.title;
    cell.type = model.title.length % [kTopicRecommedTweetImageArray count];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
