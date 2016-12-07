//
//  SoftWareDetailBodyCell.m
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareDetailBodyCell.h"
#import "Utils.h"
#import "OSCNewSoftWare.h"

@interface SoftWareDetailBodyCell ()
@property (weak, nonatomic) IBOutlet UILabel *softWareAuthorNameLb;
@property (weak, nonatomic) IBOutlet UILabel *openSourceProtocolLb;
@property (weak, nonatomic) IBOutlet UILabel *devLanguageNameLb;
@property (weak, nonatomic) IBOutlet UILabel *systemNameLb;
@property (weak, nonatomic) IBOutlet UILabel *includedDateLb;
@end

@implementation SoftWareDetailBodyCell
-(void)awakeFromNib{
    _webView.scrollView.bounces = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
}

#pragma mark --- configuration License Info
-(void)configurationRelatedInfo:(OSCNewSoftWare *)softWareModel{
    _softWareAuthorNameLb.text = softWareModel.author;
    _openSourceProtocolLb.text = softWareModel.license;
    _devLanguageNameLb.text = softWareModel.language;
    _systemNameLb.text = softWareModel.supportOS;
    _includedDateLb.text = softWareModel.collectionDate;
}
@end
