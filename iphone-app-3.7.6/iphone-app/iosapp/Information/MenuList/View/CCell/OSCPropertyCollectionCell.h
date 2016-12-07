//
//  OSCPropertyCollectionCell.h
//  iosapp
//
//  Created by 王恒 on 16/10/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CellType) {
    CellTypeNomal = 0,
    CellTypeSelect,
    CellTypeSecond,
};

@protocol OSCPropertyCollectionCellDelegate <NSObject>

- (void)deleteBtnClickWithCell:(UICollectionViewCell *)cell;

@end

@interface OSCPropertyCollectionCell : UICollectionViewCell

@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) id<OSCPropertyCollectionCellDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)beginEding;
-(void)endEding;

-(void)setCellType:(CellType)cellType WithIsUnable:(BOOL)isUnable;

-(CellType)getType;

@end
