//
//  OSCPropertyCollection.m
//  iosapp
//
//  Created by 王恒 on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPropertyCollection.h"
#import "OSCPropertyCollectionCell.h"
#import "Utils.h"

#import "UIColor+Util.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kCellWith 80
#define kCellHeight 30

@interface OSCPropertyCollection () <UICollectionViewDelegate,UICollectionViewDataSource,OSCPropertyCollectionCellDelegate>

@property (nonatomic,strong) NSMutableArray *selectTitle;
@property (nonatomic,strong) NSMutableArray *unSelectTitle;
@property (nonatomic,strong) UILongPressGestureRecognizer *longGR;
@property (nonatomic,strong) UILongPressGestureRecognizer *pressToEdit;
@property (nonatomic,strong) OSCPropertyCollectionCell *moveCell;

@end

static NSString *cellID = @"cell";
static NSString *headerID = @"header";

@implementation OSCPropertyCollection

-(instancetype)initWithFrame:(CGRect)frame WithSelectIndex:(NSInteger)index{
    _index = index;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    float spacing = 11;
    int count = (kScreenSize.width - kCellWith - 2 * spacing) / 90 + 1;
    int resultSqrt = kScreenSize.width - kCellWith - 2 * spacing;
    double number = ( resultSqrt % 90);
    if(number > 0){
        spacing = (kScreenSize.width - count * kCellWith)/ (count + 1);
    }
    layout.sectionInset = UIEdgeInsetsMake(11, spacing, 11 , spacing);
    layout.minimumLineSpacing = 11;
    layout.minimumInteritemSpacing = spacing;
    layout.itemSize = CGSizeMake(kCellWith, kCellHeight);
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if(self){
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[OSCPropertyCollectionCell class] forCellWithReuseIdentifier:cellID];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID];
        _selectTitle = [[Utils allSelectedMenuNames] mutableCopy];
        _unSelectTitle = [[Utils allUnselectedMenuNames] mutableCopy];
        self.alwaysBounceVertical = YES;
    }
    _pressToEdit = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressToEditClick:)];
    _pressToEdit.minimumPressDuration = 1;
    [self addGestureRecognizer:_pressToEdit];
    return self;
}

#pragma --mark 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return _selectTitle.count;
    }else if(_isEditing){
        return 0;
    }else{
        return _unSelectTitle.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSCPropertyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [cell endEding];
    if(indexPath.section == 0){
        if (_isEditing && indexPath.row != 0) {
            [cell beginEding];
        }
        if(indexPath.row == _index){
            if (indexPath.row >= 1) {
                [cell setCellType:CellTypeSelect WithIsUnable:NO];
            }else{
                [cell setCellType:CellTypeSelect WithIsUnable:YES];
            }
        }else{
            if (indexPath.row >= 1) {
                [cell setCellType:CellTypeNomal WithIsUnable:NO];
            }else{
                [cell setCellType:CellTypeNomal WithIsUnable:YES];
            }
        }
        cell.title = _selectTitle[indexPath.row];
    }else{
        cell.title = _unSelectTitle[indexPath.row];
        [cell endEding];
        [cell setCellType:CellTypeSecond WithIsUnable:NO];
    }
    cell.delegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 1 && !_isEditing) {
        headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, headerView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor colorWithHex:0x9d9d9d];
        label.text = @"点击添加更多栏目";
        [headerView addSubview:label];
        return headerView;
    }else {
        return nil;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0){
    if(indexPath.row != 0 || indexPath.row != 1){
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0){
    NSString *souceString = _selectTitle[sourceIndexPath.row];
    [_selectTitle removeObject:souceString];
    [_selectTitle insertObject:souceString atIndex:destinationIndexPath.row];
}

#pragma --mark 代理
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return CGSizeMake(kScreenSize.width, 0);
    }else if(_isEditing){
        return CGSizeMake(0, 0);
    }else{
        return CGSizeMake(kScreenSize.width, 40);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!_isEditing){
        if (indexPath.section == 0) {
            if ([self.propertyCollectionDelegate respondsToSelector:@selector(clickCellWithIndex:)]) {
                [self.propertyCollectionDelegate clickCellWithIndex:indexPath.row];
            }
        }else{
            NSString *currentTitle = _unSelectTitle[indexPath.row];
            [_unSelectTitle removeObjectAtIndex:indexPath.row];
            [_selectTitle insertObject:currentTitle atIndex:_selectTitle.count];
            NSIndexPath *targetIndex = [NSIndexPath indexPathForRow:_selectTitle.count-1 inSection:0];
            [collectionView moveItemAtIndexPath:indexPath toIndexPath:targetIndex];
        }
    }
}

#pragma --mark OSCPropertyCollectionCellDelegate
- (void)deleteBtnClickWithCell:(UICollectionViewCell *)cell{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSString *currentTitle = _selectTitle[indexPath.row];
    [_selectTitle removeObjectAtIndex:indexPath.row];
    [self deleteItemsAtIndexPaths:@[indexPath]];
    [_unSelectTitle insertObject:currentTitle atIndex:0];
}

#pragma --mark 实现
-(void)pressToEditClick:(UILongPressGestureRecognizer *)longGR{
    if (longGR.state == UIGestureRecognizerStateBegan) {
        if([self.propertyCollectionDelegate respondsToSelector:@selector(beginEdit)]){
            [self.propertyCollectionDelegate beginEdit];
        }
    }
}

-(void)changeStateWithEdit:(BOOL)isEditing{
    _isEditing = isEditing;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [self reloadSections:indexSet];
    for(int i = 0 ; i < _selectTitle.count ; i ++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        OSCPropertyCollectionCell *cell = (OSCPropertyCollectionCell *)[self cellForItemAtIndexPath:indexPath];
        if (i != 0) {
            if (isEditing) {
                [cell beginEding];
                [self addGestureRecognizer:self.longGR];
                [self removeGestureRecognizer:_pressToEdit];
            }else{
                [cell endEding];
                [self removeGestureRecognizer:self.longGR];
                [self addGestureRecognizer:_pressToEdit];
            }
        }
    }
}

-(void)moveCellWithGR:(UILongPressGestureRecognizer *)longGR{
    if (longGR.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:[longGR locationInView:self]];
        if (indexPath.row != 0) {
            _moveCell = (OSCPropertyCollectionCell *)[self cellForItemAtIndexPath:indexPath];
            if (_moveCell) {
                [_moveCell endEding];
                [self beginInteractiveMovementForItemAtIndexPath:indexPath];
                [UIView animateWithDuration:0.2 animations:^{
                    _moveCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
                    _moveCell.alpha = 0.8;
                }];
            }
        }
    }else if (longGR.state == UIGestureRecognizerStateChanged){
        CGPoint point = [longGR locationInView:self];
        CGPoint postionPoint = CGPointMake(point.x - kCellWith * 0.3, point.y - kCellHeight * 0.3);
        CGRect rectOfCurrent = CGRectMake(postionPoint.x, postionPoint.y, kCellWith*0.6, kCellHeight*0.6);
        UICollectionViewCell *firstCell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect rectOfFirst = firstCell.frame;
        if (CGRectIsNull(CGRectIntersection(rectOfCurrent, rectOfFirst))) {
            [self updateInteractiveMovementTargetPosition:[longGR locationInView:self]];
        }else{
            [self endInteractiveMovement];
            [UIView animateWithDuration:0.3 animations:^{
                _moveCell.transform = CGAffineTransformMakeScale(1, 1);
                _moveCell.alpha = 1;
            }];
            [_moveCell beginEding];
            _moveCell = nil;
        }
        if (_moveCell) {
            _moveCell.alpha = 0.8;
            _moveCell.transform = CGAffineTransformMakeScale( 1.2, 1.2);
        }
    }else{
        if(_moveCell){
            [self endInteractiveMovement];
            [UIView animateWithDuration:0.3 animations:^{
                _moveCell.transform = CGAffineTransformMakeScale(1, 1);
                _moveCell.alpha = 1;
            }];
            [_moveCell beginEding];
            _moveCell = nil;
        }
    }
}

-(NSArray *)CompleteAllEditings{
    return _selectTitle;
}

-(NSInteger)getSelectIdenx{
    NSInteger index = 0;
    for (int i = 0; i < _selectTitle.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        OSCPropertyCollectionCell *cell = (OSCPropertyCollectionCell *)[self cellForItemAtIndexPath:indexPath];
        if ([cell getType] == CellTypeSelect) {
            index = (NSInteger)i;
        }
    }
    return index;
}

#pragma --mark lazy load
-(UILongPressGestureRecognizer *)longGR{
    if(!_longGR){
        _longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCellWithGR:)];
        _longGR.minimumPressDuration = 0.1;
    }
    return _longGR;
}

@end
