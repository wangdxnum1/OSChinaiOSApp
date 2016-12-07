//
//  webAndAbsTableViewCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "webAndAbsTableViewCell.h"
#define Line_Spacing 0
#define Line_Height 22


@implementation webAndAbsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setAbstractText:(NSString* )abstract{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:abstract];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:Line_Spacing];
    [paragraphStyle setMinimumLineHeight:Line_Height];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [abstract length])];
    _abstractLabel.attributedText = attributedString;

}

@end
