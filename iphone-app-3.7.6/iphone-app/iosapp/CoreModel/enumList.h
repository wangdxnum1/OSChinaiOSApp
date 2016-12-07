//
//  enumList.h
//  iosapp
//
//  Created by Graphic-one on 16/5/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#ifndef enumList_h
#define enumList_h

typedef NS_ENUM(NSUInteger, InformationType)
{
    InformationTypeLinkNews = 0,//链接新闻
    InformationTypeSoftWare = 1,//软件推荐
    InformationTypeForum = 2,//讨论区帖子（问答）
    InformationTypeBlog = 3,//博客
    InformationTypeTranslation = 4,//翻译文章
    InformationTypeActivity = 5,//活动类型
    InformationTypeInfo = 6,//资讯
    
    InformationTypeUserCenter = 11,//用户中心
    
    InformationTypeTweet = 100//动弹（评论）类型
};

typedef NS_ENUM(NSInteger, UserGenderType)
{
    UserGenderTypeUnknown = 0 ,//未知
    UserGenderTypeMan,//男性
    UserGenderTypeWoman //女性
};

typedef NS_ENUM(NSInteger, UserRelationStatus)
{
    UserRelationStatusMutual = 1 ,//双方互为粉丝
    UserRelationStatusSelf = 2 ,//你单方面关注他
    UserRelationStatusOther = 3 ,//他单方面关注我
    UserRelationStatusNone = 4 //互不关注
};

typedef NS_ENUM (NSUInteger, ActivityStatus){
    ActivityStatusEnd = 1,// 活动已经结束
    ActivityStatusHaveInHand,//活动进行中
    ActivityStatusClose//活动报名已经截止
};

typedef NS_ENUM (NSUInteger, ActivityType){
    ActivityTypeOSChinaMeeting = 1,//源创会
    ActivityTypeTechnical,//技术交流
    ActivityTypeOther,// 其他
    ActivityTypeBelow//站外活动(当为站外活动的时候，href为站外活动报名地址)
};

typedef NS_ENUM(NSUInteger, ApplyStatus) {
    ApplyStatusUnSignUp = -1,//未报名
    ApplyStatusAudited = 0 ,//审核中
    ApplyStatusDetermined = 1 ,//已经确认
    ApplyStatusAttended,//已经出席
    ApplyStatusCanceled,//已取消
    ApplyStatusRejected,//已拒绝
};

typedef NS_ENUM(NSInteger,OSCInformationListBannerType) {
    OSCInformationListBannerTypeNone = 0,//没有banner
    OSCInformationListBannerTypeSimple = 1,//通用banner (UIImageView显示图片 + UILabel显示title)
    OSCInformationListBannerTypeSimple_Blogs = 2,//自定义banner (用于blog列表展示)
    OSCInformationListBannerTypeCustom_Activity = 3,//自定义banner (用于activity列表展示)
};

#define kTopicRecommedTweetImageArray @[@"bg_topic_1",@"bg_topic_2",@"bg_topic_3",@"bg_topic_4",@"bg_topic_5"]

typedef NS_ENUM(NSInteger,TopicRecommedTweetType){
    TopicRecommedTweetTypeFirst = 0,
    TopicRecommedTweetTypeSecond = 1,
    TopicRecommedTweetTypeThird = 2,
    TopicRecommedTweetTypeForth = 3,
    TopicRecommedTweetTypeFifth = 4,
};

/** 机型设备信息 用DeviceResolution作为下标访问*/
#define kDeviceArray @[@"iPhone_4",@"iPhone_4s",@"iPhone_5",@"iPhone_5c",@"iPhone_5s",@"iPhone_6",@"iPhone_6p",@"iPhone_6s",@"iPhone_6sp",@"iPhone_se",@"iPhone_7",@"iPhone_7p",@"Simulator"]

typedef NS_ENUM(NSUInteger,DeviceResolution){
    Device_iPhone_4 = 0 ,
    Device_iPhone_4s    ,
    Device_iPhone_5     ,
    Device_iPhone_5c    ,
    Device_iPhone_5s    ,
    Device_iPhone_6     ,
    Device_iPhone_6p    ,
    Device_iPhone_6s    ,
    Device_iPhone_6sp   ,
    Device_iPhone_se    ,
    Device_iPhone_7     ,
    Device_iPhone_7p    ,
    Device_Simulator
};

typedef NS_ENUM(NSUInteger,SystemVersion){
    Version_iOS7 = 0    ,
    Version_iOS8        ,
    Version_iOS9        ,
    Version_iOS10       ,
    Version_noSupport
};

#endif /* enumList_h */
