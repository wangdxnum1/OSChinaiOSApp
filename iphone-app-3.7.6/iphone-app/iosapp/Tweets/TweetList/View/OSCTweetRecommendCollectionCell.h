//
//  OSCTweetRecommendCollectionCell.h
//  iosapp
//
//  Created by 王恒 on 16/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"
#import "OSCTweetItem.h"

@interface OSCTweetRecommendCollectionCell : UICollectionViewCell

@property (nonatomic,strong) NSArray<OSCTweetItem *> *contentArray;
@property (nonatomic,assign) NSInteger peopleCount;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) TopicRecommedTweetType type;

- (instancetype)initWithFrame:(CGRect)frame;

@end




@interface CellLineView : UIView

@property (nonatomic,strong) NSString *contentStr;
@property (nonatomic,strong) NSString *imageUrl;

- (void)showCurLineCell;
- (void)hideCurLineCell;

@end



@interface CellBottomView : UIView

@property (nonatomic,strong) NSString *peopleNumber;

@end
