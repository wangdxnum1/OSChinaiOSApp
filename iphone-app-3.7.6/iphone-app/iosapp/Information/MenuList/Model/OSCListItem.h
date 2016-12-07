//
//  OSCListItem.h
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "enumList.h"

/** nomal setting*/
#define kScreen_bound_width [UIScreen mainScreen].bounds.size.width
#define cell_padding_left 16
#define cell_padding_right cell_padding_left
#define cell_padding_top 16
#define cell_padding_bottom cell_padding_top
#define fontLineSpace 10

/** SPACE:垂直方向的间距 space:水平方向的间距*/
/** blog cell setting*/
#define blogCell_titleLB_Font_Size 15
#define blogCell_descLB_Font_Size 13
#define blogCell_titleLB_SPACE_descLB 4
#define blogCell_descLB_SPACE_infoBar 6
#define blogCell_infoBar_Height 13

/** activity cell setting (固定高度)*/
#define activityCell_rowHeigt 122

/** questions cell setting*/
#define questionsCell_titleLB_Font_Size 15
#define questionsCell_descLB_Font_Size 14
#define questionsCell_infoLB_Font_Size 10

#define questionsCell_titleLB_Padding_Left 70
#define questionsCell_descLB_Padding_Left 70
#define questionsCell_titleLB_SPACE_descLB 5
#define questionsCell_descLB_SPACE_infoBar 6

#define questionsCell_count_icon_count_space 2
#define questionsCell_icon_count_icon_space 12
#define questionsCell_icon_width 13
#define questionsCell_icon_height 10
#define questionsCell_infoBar_Height 14

/** information cell setting*/
#define informationCell_titleLB_Font_Size 15
#define informationCell_descLB_Font_Size 13
#define informationCell_infoBar_Font_Size 10
#define informationCell_titleLB_SPACE_descLB 5
#define informationCell_descLB_SPACE_infoBar 8
#define informationCell_infoBar_Height 14

#define informationCell_count_icon_count_space 2
#define informationCell_icon_width 13
#define informationCell_icon_height 10

/*  QuestionCell_LayoutInfo cell setting  */
#define blogsCell_titleLB_Font_Size 15
#define blogsCell_descLB_Font_Size 14
#define blogsCell_infoLB_Font_Size 10

//#define blogsCell_titleLB_Padding_Left 16
//#define blogsCell_descLB_Padding_Left 16
#define blogsCell_titleLB_SPACE_descLB 5
#define blogsCell_descLB_SPACE_infoBar 6

#define blogsCell_count_icon_count_space 2
#define blogsCell_icon_count_icon_space 12
#define blogsCell_icon_width 13
#define blogsCell_icon_height 10
#define blogsCell_infoBar_Height 14

typedef NS_ENUM(NSInteger,OSCListCellType) {
    OSCListCellType_Single_Nomal ,
    OSCListCellType_Single_Special ,
    OSCListCellType_Divide,
    OSCListCellType_Larger,
    OSCListCellType_Unkonw,
};

@class OSCAuthor , OSCListItem_Image , OSCListItem_Statistics , OSCListItem_Extra , InformationCell_layoutInfo, QuestionCell_LayoutInfo, BlogCell_LayoutInfo,OSCMenuItem;
@interface OSCListItem : NSObject

@property (nonatomic,strong) OSCMenuItem* menuItem;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSAttributedString* attributedTitle;

@property (nonatomic,strong) NSString* body;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) InformationType type;

@property (nonatomic,strong) OSCAuthor* author;

@property (nonatomic,strong) OSCListItem_Image* image;

@property (nonatomic,strong) NSArray<NSString* >* tags;
@property (nonatomic,assign) BOOL isRecommend, isOriginal, isAd, isStick ,isToday;

@property (nonatomic,strong) OSCListItem_Statistics* statistics;

@property (nonatomic,strong) OSCListItem_Extra* extra;

@property (nonatomic,assign) OSCListCellType cellType;

//layout info
- (void)getLayoutInfo;
@property (nonatomic,assign) CGFloat rowHeight;///全部cell使用到info
@property (nonatomic,strong) InformationCell_layoutInfo* informationLayoutInfo;///咨询列表cell使用到的info
@property (nonatomic, strong) QuestionCell_LayoutInfo * questionLayoutInfo; //问答列表cell
@property (nonatomic, strong) BlogCell_LayoutInfo *blogLayoutInfo; //博客列表cell

@end




@interface OSCAuthor : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* portrait;

@end




typedef NS_ENUM(NSInteger,OSCListItemImageType){
    OSCListItemImageTypeNomal = 1,
    OSCListItemImageTypeLarger = 2,
    OSCListItemImageTypeDivide = 3,
};
@interface OSCListItem_Image : NSObject

@property (nonatomic,assign) OSCListItemImageType type;

@property (nonatomic,strong) NSArray* href;

@end




@interface OSCListItem_Statistics : NSObject

@property (nonatomic,assign) NSInteger comment;

@property (nonatomic,assign) NSInteger view;

@end




@interface OSCListItem_Extra : NSObject

@property (nonatomic,strong) NSString* eventStartDate;

@property (nonatomic,strong) NSString* eventEndDate;

@property (nonatomic,assign) NSInteger eventApplyCount;

@property (nonatomic,assign) ActivityStatus eventStatus;

@property (nonatomic,assign) ActivityType eventType;

@end



#pragma mark - Asynchronous display layout info
/** layout info Class */
@interface InformationCell_layoutInfo : NSObject

@property (nonatomic,assign) CGRect titleLbFrame;
@property (nonatomic,assign) CGRect contentLbFrame;
@property (nonatomic,assign) CGRect timeLbFrame;
@property (nonatomic,assign) CGRect commentImgFrame;
@property (nonatomic,assign) CGRect commentCountLbFrame;

@end

/*  question layout info   */
@interface QuestionCell_LayoutInfo : NSObject
@property (nonatomic, assign) CGRect protraitImgFrame;
@property (nonatomic, assign) CGRect titleLbFrame;
@property (nonatomic, assign) CGRect descLbFrame;
@property (nonatomic, assign) CGRect userNameLbFrame;
@property (nonatomic, assign) CGRect timeLbFrame;
@property (nonatomic, assign) CGRect viewCountImgFrame;
@property (nonatomic, assign) CGRect viewCountLbFrame;
@property (nonatomic, assign) CGRect commentCountImgFrame;
@property (nonatomic, assign) CGRect commentCountLbFrame;
@end

@interface BlogCell_LayoutInfo : NSObject
@property (nonatomic, assign) CGRect titleLbFrame;
@property (nonatomic, assign) CGRect descLbFrame;
@property (nonatomic, assign) CGRect userNameLbFrame;
@property (nonatomic, assign) CGRect timeLbFrame;
@property (nonatomic, assign) CGRect viewCountImgFrame;
@property (nonatomic, assign) CGRect viewCountLbFrame;
@property (nonatomic, assign) CGRect commentCountImgFrame;
@property (nonatomic, assign) CGRect commentCountLbFrame;

@end


