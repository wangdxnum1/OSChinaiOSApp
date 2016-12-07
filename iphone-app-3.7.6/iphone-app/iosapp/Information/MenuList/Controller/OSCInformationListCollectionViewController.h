//
//  OSCInformationListCollectionViewController.h
//  iosapp
//
//  Created by Graphic-one on 16/10/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InformationListCollectionDelegate <NSObject>

- (void)ScrollViewDidEndWithIndex:(NSInteger)index;

@end

@class OSCMenuItem;
@interface OSCInformationListCollectionViewController : UICollectionViewController

@property (nonatomic,strong) NSArray<OSCMenuItem* >* menuItem;
@property (nonatomic,assign) id<InformationListCollectionDelegate> informationListCollectionDelegate;

- (void)beginRefreshWithIndex:(NSInteger)index;

@end
