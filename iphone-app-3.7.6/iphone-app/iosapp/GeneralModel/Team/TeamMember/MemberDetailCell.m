//
//  MemberDetailCell.m
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MemberDetailCell.h"
#import "Utils.h"
#import "NSString+FontAwesome.h"
@implementation MemberDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)initSubviews
{
    _portraitIv = [UIImageView new];
    _portraitIv.contentMode = UIViewContentModeScaleAspectFit;
    [_portraitIv setCornerRadius:5];
    [self.contentView addSubview:_portraitIv];
    
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    _nameLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_nameLabel];
    
    _eMailLabel = [UILabel new];
    _eMailLabel.font = [UIFont systemFontOfSize:14];
    _eMailLabel.textColor = [UIColor titleColor];
    _eMailLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_eMailLabel];
    
    _phoneLabel = [UILabel new];
    _phoneLabel.numberOfLines = 0;
    _phoneLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _phoneLabel.font = [UIFont systemFontOfSize:14];
    _phoneLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_phoneLabel];
    
    _addressLabel = [UILabel new];
    _addressLabel.numberOfLines = 0;
    _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _addressLabel.font = [UIFont systemFontOfSize:14];
    _addressLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_addressLabel];
    
    _phoneIconLabel = [UILabel new];
    _phoneIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:40];
    _phoneIconLabel.textColor = [UIColor nameColor];//colorWithHex:0x15A230
    [self.contentView addSubview:_phoneIconLabel];
    
    
    _phoneIconLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeACall)];
    [_phoneIconLabel addGestureRecognizer:tap];
}
-(void)makeACall
{
    if ([_phoneLabel.text length]>=2) {
        UIWebView *callWebview =[[UIWebView alloc] init];
        NSString *telUrl = [NSString stringWithFormat:@"tel://%@",_phoneLabel.text];
        NSURL *telURL =[NSURL URLWithString:telUrl];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.contentView addSubview:callWebview];
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_phoneLabel.text]]];
    }
}
- (void)setLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portraitIv, _nameLabel, _eMailLabel, _phoneLabel, _addressLabel,_phoneIconLabel);

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portraitIv(60)]"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_portraitIv(60)]-20-[_nameLabel]-10-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-7-[_eMailLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_eMailLabel]-7-[_phoneLabel]-7-[_addressLabel]-7-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-7-[_phoneIconLabel(40)]" options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_eMailLabel]-7-[_phoneIconLabel(40)]-10-|" options:0 metrics:nil views:views]];
    
}


- (void)setContentWithTeamMember:(TeamMember *)teamMember
{
    [_portraitIv loadPortrait:teamMember.portraitURL];
    _nameLabel.text = [teamMember.name length]>0?teamMember.name:@"未填写姓名";
    _eMailLabel.text = [teamMember.email length]>0?teamMember.email:@"未填写邮箱";
    _phoneLabel.text = [teamMember.telephone length]>0?teamMember.telephone:@"未填写电话";
    _addressLabel.text = [teamMember.location length]>0?teamMember.location:@"未填写地址";
    
    
    if ([teamMember.telephone length] <= 0) {
        _phoneIconLabel.hidden = YES;
    }else {
        [_phoneIconLabel setText:[NSString fontAwesomeIconStringForEnum:FAPhone]];
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
