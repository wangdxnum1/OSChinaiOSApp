//
//  OSCPropertyCollection.h
//  iosapp
//
//  Created by 王恒 on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OSCPropertyCollectionDelegate <NSObject>

- (void)clickCellWithIndex:(NSInteger)index;
- (void)beginEdit;

@end

@interface OSCPropertyCollection : UICollectionView

@property (nonatomic,assign) id<OSCPropertyCollectionDelegate> propertyCollectionDelegate;
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) NSInteger index;

-(instancetype)initWithFrame:(CGRect)frame WithSelectIndex:(NSInteger)index;

/**排序*/
-(void)changeStateWithEdit:(BOOL)isEditing;

/**完成所有的编辑*/
-(NSArray *)CompleteAllEditings;

-(NSInteger)getSelectIdenx;

@end
