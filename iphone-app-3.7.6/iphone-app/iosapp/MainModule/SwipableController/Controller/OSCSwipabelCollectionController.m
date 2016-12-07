//
//  OSCSwipabelCollectionController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSwipabelCollectionController.h"
#import "OSCSwipableCell.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define titleBar_height 36
#define navigationBar_height 64
#define tabBar_height 44

@interface OSCSwipabelCollectionController () <UICollectionViewDelegate, UICollectionViewDataSource, OSCSwipableCellDelegate>

@property (nonatomic, strong) NSArray *controlles;
@property (nonatomic, assign) BOOL isTabberHidden;


@end

@implementation OSCSwipabelCollectionController

static NSString * const reuserSwipabelCellIdentifier = @"OSCSwipableCell";

- (instancetype)initWithFrame:(CGRect)frame SubController:(NSArray *)subControllers tabbarHidden:(BOOL)isHidden
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = (CGSize){CGRectGetWidth(frame), CGRectGetHeight(frame)};
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        self.controlles = subControllers.mutableCopy;
        self.isTabberHidden = isHidden;
        for (UIViewController *controller in subControllers) {
            [self addChildViewController:controller];
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    [self.collectionView registerClass:[OSCSwipableCell class] forCellWithReuseIdentifier:reuserSwipabelCellIdentifier];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.controlles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSCSwipableCell *cell = [OSCSwipableCell returnReuseSwipableTweetCollectionViewCell:self.collectionView identifier:reuserSwipabelCellIdentifier indexPath:indexPath subViewController:self.controlles[indexPath.row]];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - OSCSwipableCellDelegate
- (void)SwipableListCollectionViewCell:(OSCSwipableCell *)clickCell didClickTableViewCell:(__kindof UITableViewCell *)tableViewCell pushViewController:(UIViewController *)pushController
{
    [self.navigationController pushViewController:pushController animated:YES];
}
@end
