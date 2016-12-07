//
//  OSCListItem.m
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCListItem.h"
#import "OSCMenuItem.h"

#import "Utils.h"

static NSString* const kRecommend = @"recommend";
static NSString* const kOriginal = @"original";
static NSString* const kAd = @"ad";
static NSString* const kStick = @"stick";

@implementation OSCListItem
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"tags" : [NSString class],
             };
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSArray* tags = dic[@"tags"];
    for (NSString* tagString in tags) {
        if ([tagString isEqualToString:kRecommend]) { _isRecommend = YES; }
        
        if ([tagString isEqualToString:kOriginal]) { _isOriginal = YES; }
        
        if ([tagString isEqualToString:kAd]) { _isAd = YES; }
        
        if ([tagString isEqualToString:kStick]) { _isStick = YES; }
    }
    return YES;
}

- (void)getLayoutInfo{
    CGFloat rowHeight = 0;
    
    switch (_type) {
            
        case InformationTypeBlog:{
            BlogCell_LayoutInfo *blogInfo = [BlogCell_LayoutInfo new];
            
            /** titleLb */
            CGSize titleSize = [[self attributedTitle] boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right), (blogCell_titleLB_Font_Size * 2 + [UIFont systemFontOfSize:blogCell_titleLB_Font_Size].lineHeight)}
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    context:nil].size;
            blogInfo.titleLbFrame = (CGRect){{cell_padding_left, cell_padding_top}, {(kScreen_bound_width - cell_padding_left - cell_padding_right) , (titleSize.height)}};
            
            /** descLb */
#pragma TODO : boundingRectWithSize: 计算不准
            //            CGSize descSize = (CGSize)[_body boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right),
            //                                                                           (blogCell_descLB_Font_Size * 2 + [UIFont systemFontOfSize:blogCell_descLB_Font_Size].lineHeight)}
            //                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
            //                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogCell_descLB_Font_Size]}
            //                                                  context:nil].size;
            CGSize descSize = {(kScreen_bound_width - cell_padding_left - cell_padding_right) , (blogCell_descLB_Font_Size * 2 + [UIFont systemFontOfSize:blogCell_descLB_Font_Size].lineHeight)};
            blogInfo.descLbFrame = (CGRect){{cell_padding_left, (cell_padding_top + titleSize.height + blogCell_titleLB_SPACE_descLB)}, descSize };
            
            /** nameLb */
            CGSize nameSize = (CGSize)[_author.name sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size]}];
            blogInfo.userNameLbFrame = (CGRect){{cell_padding_left, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar}, {nameSize.width, blogsCell_infoBar_Height}};
            /** timeLb */
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate* date = [formatter dateFromString:_pubDate];
            
            CGSize timeSize = (CGSize)[[date timeAgoSinceNow] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size]} ];
            
            blogInfo.timeLbFrame = (CGRect){{cell_padding_left + nameSize.width + 5, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar}, {timeSize.width, blogsCell_infoBar_Height}};
            
            /** commentLb */
            CGSize commentSize = (CGSize)[[NSString stringWithFormat:@"%ld", (long)_statistics.comment] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size]}];
            blogInfo.commentCountLbFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar}, {commentSize.width, blogsCell_infoBar_Height}};
            /** commentImageView */
            blogInfo.commentCountImgFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - blogsCell_icon_width - blogsCell_count_icon_count_space, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar + blogsCell_count_icon_count_space}, {blogsCell_icon_width, blogsCell_icon_height}};
            /** viewCountLb */
            CGSize viewsSize = (CGSize)[[NSString stringWithFormat:@"%ld", (long)_statistics.view] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size]}];
            blogInfo.viewCountLbFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - blogsCell_icon_width - blogsCell_count_icon_count_space - viewsSize.width - blogsCell_icon_count_icon_space, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar}, {viewsSize.width, blogsCell_infoBar_Height}};
            /** viewCountImageView */
            blogInfo.viewCountImgFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - blogsCell_icon_width - blogsCell_count_icon_count_space - viewsSize.width - blogsCell_icon_count_icon_space - blogsCell_icon_width - blogsCell_count_icon_count_space, cell_padding_top + titleSize.height + blogsCell_titleLB_SPACE_descLB + descSize.height + blogsCell_descLB_SPACE_infoBar + blogsCell_count_icon_count_space}, {blogsCell_icon_width, blogsCell_icon_height}};
            
            rowHeight += cell_padding_top;
            rowHeight += titleSize.height;
            rowHeight += blogsCell_titleLB_SPACE_descLB;
            rowHeight += descSize.height;
            rowHeight += blogsCell_descLB_SPACE_infoBar;
            rowHeight += blogsCell_infoBar_Height;
            rowHeight += cell_padding_bottom;
            
            _blogLayoutInfo = blogInfo;
            _rowHeight = ceil(rowHeight);
            break;
        }
            
        case InformationTypeForum:{
            if ([_menuItem.token isEqualToString:@"d6112fa662bc4bf21084670a857fbd20"]) {//推荐列表 问答
                _rowHeight = [self infomationLayoutHeight:rowHeight];
                
            } else {
                QuestionCell_LayoutInfo *questionInfo = [QuestionCell_LayoutInfo new];
                
                questionInfo.protraitImgFrame = (CGRect){{16, 16}, {45, 45}};
                /** titleLb */
                CGSize titleSize = (CGSize)[_title boundingRectWithSize:(CGSize){(kScreen_bound_width - questionsCell_titleLB_Padding_Left - cell_padding_right), questionsCell_titleLB_Font_Size * 2 + [UIFont systemFontOfSize:questionsCell_titleLB_Font_Size].lineHeight}
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_titleLB_Font_Size]}
                                                                context:nil].size;
                questionInfo.titleLbFrame = (CGRect){{questionsCell_titleLB_Padding_Left, cell_padding_top}, {kScreen_bound_width - questionsCell_titleLB_Padding_Left - cell_padding_right , titleSize.height}};
                /** descLb */
                CGSize descSize = (CGSize)[(_body.length > 0 ? _body : @"[图片]") boundingRectWithSize:(CGSize){(kScreen_bound_width - questionsCell_descLB_Padding_Left - cell_padding_right), questionsCell_descLB_Font_Size * 2 + [UIFont systemFontOfSize:questionsCell_descLB_Font_Size].lineHeight }
                                                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_descLB_Font_Size]}
                                                                                             context:nil].size;
                questionInfo.descLbFrame = (CGRect){{questionsCell_descLB_Padding_Left, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB}, descSize};
                
                /** nameLb */
                CGSize nameSize = (CGSize)[_author.name sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_infoLB_Font_Size]}];
                questionInfo.userNameLbFrame = (CGRect){{questionsCell_descLB_Padding_Left, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar}, {nameSize.width, questionsCell_infoBar_Height}};
                /** timeLb */
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate* date = [formatter dateFromString:_pubDate];
                
                CGSize timeSize = (CGSize)[[date timeAgoSinceNow] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_infoLB_Font_Size]} ];
                
                questionInfo.timeLbFrame = (CGRect){{questionsCell_descLB_Padding_Left + nameSize.width + 5, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar}, {timeSize.width, questionsCell_infoBar_Height}};
                
                /** commentLb */
                CGSize commentSize = (CGSize)[[NSString stringWithFormat:@"%ld", (long)_statistics.comment] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_infoLB_Font_Size]}];
                questionInfo.commentCountLbFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar}, {commentSize.width, questionsCell_infoBar_Height}};
                /** commentImageView */
                questionInfo.commentCountImgFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - questionsCell_icon_width - questionsCell_count_icon_count_space, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar + questionsCell_count_icon_count_space}, {questionsCell_icon_width, questionsCell_icon_height}};
                /** viewCountLb */
                CGSize viewsSize = (CGSize)[[NSString stringWithFormat:@"%ld", (long)_statistics.view] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:questionsCell_infoLB_Font_Size]}];
                questionInfo.viewCountLbFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - questionsCell_icon_width - questionsCell_count_icon_count_space - viewsSize.width - questionsCell_icon_count_icon_space, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar}, {viewsSize.width, questionsCell_infoBar_Height}};
                /** viewCountImageView */
                questionInfo.viewCountImgFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - questionsCell_icon_width - questionsCell_count_icon_count_space - viewsSize.width - questionsCell_icon_count_icon_space - questionsCell_icon_width - questionsCell_count_icon_count_space, cell_padding_top + titleSize.height + questionsCell_titleLB_SPACE_descLB + descSize.height + questionsCell_descLB_SPACE_infoBar + questionsCell_count_icon_count_space}, {questionsCell_icon_width, questionsCell_icon_height}};
                
                rowHeight += cell_padding_top;
                rowHeight += titleSize.height;
                rowHeight += questionsCell_titleLB_SPACE_descLB;
                rowHeight += questionInfo.descLbFrame.size.height;
                rowHeight += questionsCell_descLB_SPACE_infoBar;
                rowHeight += questionsCell_infoBar_Height;
                rowHeight += cell_padding_bottom;
                
                _questionLayoutInfo = questionInfo;
                _rowHeight = ceil(rowHeight);
            }
            
            break;
        }
            
        case InformationTypeActivity:{
            if ([_menuItem.token isEqualToString:@"d6112fa662bc4bf21084670a857fbd20"]) {//推荐列表 活动
                _rowHeight = [self infomationLayoutHeight:rowHeight];
                
            } else {
                _rowHeight = activityCell_rowHeigt;
            }
            
            break;
        }
            
        default:{
            /** InformationCell_layoutInfo */
            
            _rowHeight = [self infomationLayoutHeight:rowHeight];
            
            break;
        }
    }
}

/** InformationCell_layoutInfo */
- (CGFloat)infomationLayoutHeight:(CGFloat)rowHeight
{
    InformationCell_layoutInfo* infoLayoutInfo = [InformationCell_layoutInfo new];
    
    /** titleLb */
    CGSize titleSize = (CGSize)[[self attributedTitle] boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right), informationCell_titleLB_Font_Size * 2 + [UIFont systemFontOfSize:informationCell_titleLB_Font_Size].lineHeight}
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    context:nil].size;
    infoLayoutInfo.titleLbFrame = (CGRect){{cell_padding_left, cell_padding_top},{kScreen_bound_width - cell_padding_left - cell_padding_right , titleSize.height}};
    /** descLb */
    CGSize descSize = (CGSize)[_body boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right), informationCell_descLB_Font_Size * 2 + [UIFont systemFontOfSize:informationCell_descLB_Font_Size].lineHeight }
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:informationCell_descLB_Font_Size]}
                                                  context:nil].size;
    infoLayoutInfo.contentLbFrame = (CGRect){{cell_padding_left, cell_padding_top + titleSize.height + informationCell_titleLB_SPACE_descLB}, {kScreen_bound_width - cell_padding_left - cell_padding_right , descSize.height}};
    
    /** timeLb */
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:_pubDate];
    
    CGSize timeSize = (CGSize)[[date timeAgoSinceNow] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:informationCell_infoBar_Font_Size]} ];
    
    infoLayoutInfo.timeLbFrame = (CGRect){{cell_padding_left, cell_padding_top + titleSize.height + informationCell_titleLB_SPACE_descLB + descSize.height + informationCell_descLB_SPACE_infoBar}, {timeSize.width, informationCell_infoBar_Height}};
    
    /** commentLb */
    CGSize commentSize = (CGSize)[[NSString stringWithFormat:@"%ld",(long)_statistics.comment] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:informationCell_infoBar_Font_Size]}];
    infoLayoutInfo.commentCountLbFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width, cell_padding_top + titleSize.height + informationCell_titleLB_SPACE_descLB + descSize.height + informationCell_descLB_SPACE_infoBar}, {commentSize.width, informationCell_infoBar_Height}};
    /** commentImageView */
    infoLayoutInfo.commentImgFrame = (CGRect){{kScreen_bound_width - cell_padding_right - commentSize.width - informationCell_count_icon_count_space - informationCell_icon_width, cell_padding_top + titleSize.height + informationCell_titleLB_SPACE_descLB + descSize.height + informationCell_descLB_SPACE_infoBar + informationCell_count_icon_count_space}, {informationCell_icon_width, informationCell_icon_height}};
    
    rowHeight += cell_padding_top;
    rowHeight += titleSize.height;
    rowHeight += informationCell_titleLB_SPACE_descLB;
    rowHeight += infoLayoutInfo.contentLbFrame.size.height;
    rowHeight += informationCell_descLB_SPACE_infoBar;
    rowHeight += informationCell_infoBar_Height;
    rowHeight += cell_padding_bottom;
    
    _informationLayoutInfo = infoLayoutInfo;
    
    return ceil(rowHeight);
}

- (NSAttributedString *)attributedTitle{
    if (!_attributedTitle) {
        
        NSMutableAttributedString* mutableAttributeString = [[NSMutableAttributedString alloc] init];
        
        switch (_menuItem.type) {
            case InformationTypeInfo:
            {
                if ([_menuItem.subtype isEqualToString:@"1"]) {
                    [mutableAttributeString appendAttributedString:[self todayIconAttributedString]];
                }
                
                break;
            }
            case InformationTypeSoftWare:
            {
                [mutableAttributeString appendAttributedString:[self todayIconAttributedString]];
                
                break;
            }
            case InformationTypeBlog:
            {
                [mutableAttributeString appendAttributedString:[self todayIconAttributedString]];
                
                if (_isRecommend) {
                    NSTextAttachment* textAttachment = [NSTextAttachment new];
                    textAttachment.image = [UIImage imageNamed:@"ic_label_recommend"];
                    [textAttachment adjustY:-3];
                    [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
                    [mutableAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
                }
                if (_isOriginal) {
                    NSTextAttachment* textAttachment = [NSTextAttachment new];
                    textAttachment.image = [UIImage imageNamed:@"ic_label_originate"];
                    [textAttachment adjustY:-3];
                    [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
                } else {
                    NSTextAttachment* textAttachment = [NSTextAttachment new];
                    textAttachment.image = [UIImage imageNamed:@"ic_label_reprint"];
                    [textAttachment adjustY:-3];
                    [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
                }
                [mutableAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
                
                break;
            }
            case InformationTypeTranslation:
            {
                [mutableAttributeString appendAttributedString:[self todayIconAttributedString]];
                
                break;
            }
            default:
                break;
        }
        
        if (_title.length > 0) {
            NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:_title
                                                                                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:blogCell_titleLB_Font_Size]}];
            [mutableAttributeString appendAttributedString:titleAttr];
        }

        _attributedTitle = mutableAttributeString;
    }
    return _attributedTitle;
}
//today icon
- (NSMutableAttributedString *)todayIconAttributedString
{
    NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] init];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* systemDateStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"systemDate"];
    if (!systemDateStr) { systemDateStr = [formatter stringFromDate:[NSDate date]]; }
    
    NSDate* date = [formatter dateFromString:_pubDate];
    NSDate* systemDate = [formatter dateFromString:systemDateStr];
    NSDate *subDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", [systemDateStr componentsSeparatedByString:@" "][0]]];
    int timeSecond = [systemDate timeIntervalSince1970] - [date timeIntervalSince1970];
    int subTime = [systemDate timeIntervalSince1970] - [subDate timeIntervalSince1970];
    
    if (timeSecond <= subTime) {
        _isToday = YES;
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"ic_label_today"];
        [textAttachment adjustY:-3];
        [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
        [mutableAttributeString appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    } else {
        _isToday = NO;
    }
    
    return mutableAttributeString;
}

@end


@implementation OSCAuthor

@end


@implementation OSCListItem_Image
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"href" : [NSString class],
             };
}
@end


@implementation OSCListItem_Statistics

@end


@implementation OSCListItem_Extra

@end






#pragma mark - Asynchronous display layout info
/** layout info Class */
@implementation InformationCell_layoutInfo

@end

#pragma mark - QuestionCell_LayoutInfo
@implementation QuestionCell_LayoutInfo

@end


#pragma mark - BlogCell_LayoutInfo
@implementation BlogCell_LayoutInfo

@end




