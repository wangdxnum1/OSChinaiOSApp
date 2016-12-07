//
//  OSCRandomGiftLargerImageView.m
//  iosapp
//
//  Created by Graphic-one on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCRandomGiftLargerImageView.h"
#import "OSCRandomMessage.h"

#import "UIImageView+Util.h"
#import <UIImageView+WebCache.h>

@interface OSCRandomGiftLargerImageView ()
@property (weak, nonatomic) IBOutlet UIImageView *discoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftItemButton;
@property (weak, nonatomic) IBOutlet UIButton *rightItemButton;
@end

@implementation OSCRandomGiftLargerImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _leftIsAvailable = YES;
    _rightIsAvailable = YES;
    _discoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _discoverImageView.clipsToBounds = YES;
}

+ (instancetype)randomGiftLargerImageView{
    return [[NSBundle mainBundle]loadNibNamed:@"OSCRandomGiftLargerImageView" owner:nil options:nil].lastObject;
}

#pragma mark --- setting Item Available
- (void)setLeftIsAvailable:(BOOL)leftIsAvailable{
    _leftIsAvailable = leftIsAvailable;
    
    if (leftIsAvailable) {
        _leftItemButton.userInteractionEnabled = YES;
    }else{
        _leftItemButton.userInteractionEnabled = NO;
    }
}

- (void)setRightIsAvailable:(BOOL)rightIsAvailable{
    _rightIsAvailable = rightIsAvailable;
    
    if (rightIsAvailable) {
        _rightItemButton.userInteractionEnabled = YES;
    }else{
        _rightItemButton.userInteractionEnabled = NO;
    }
}

#pragma mark --- setting Model
- (void)setRandomGiftItem:(OSCRandomGift *)randomGiftItem{
    _randomGiftItem = randomGiftItem;
    
    [self.discoverImageView sd_setImageWithURL:[NSURL URLWithString:randomGiftItem.pic]];
    self.giftDescLabel.text = randomGiftItem.name;
}




#pragma mark --- delegate Method 

- (IBAction)clickLeftItem:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(randomGiftLargerImageViewDidClickLeftItem:)]) {
        [_delegate randomGiftLargerImageViewDidClickLeftItem:self];
    }
}
- (IBAction)clickRightItem:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(randomGiftLargerImageViewDidClickRightItem:)]) {
        [_delegate randomGiftLargerImageViewDidClickRightItem:self];
    }
}

@end
