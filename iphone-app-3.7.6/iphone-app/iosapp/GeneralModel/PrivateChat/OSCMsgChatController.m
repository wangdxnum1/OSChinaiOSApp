//
//  OSCMsgChatController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

//可删除文件
#import "OSCMsgChatController.h"
#import "OSCPrivateChatController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "OSCEditingBar.h"

#import <MBProgressHUD.h>
#import <Masonry.h>

@interface OSCMsgChatController ()

@property (nonatomic, strong) OSCPrivateChatController* privateChatVC;
@property (nonatomic, strong) OSCEditingBar *oscEditingBar;

@end

@implementation OSCMsgChatController{
    NSInteger _authorId;
}
#pragma mark --- initialize method
- (instancetype)initWithAuthorId:(NSInteger)authorId userName:(NSString *)name{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.navigationItem.title = name;
        
        _authorId = authorId;
        _privateChatVC = [[OSCPrivateChatController alloc]initWithAuthorId:_authorId];
        _oscEditingBar = [[OSCEditingBar alloc] initWithModeSwitchButton:YES];
        
        [self.view addSubview:_oscEditingBar];
        [self addChildViewController:_privateChatVC];
        
        [self setUpBlock];
    }
    return self;
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)setLayout{
    [self.view addSubview:_privateChatVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"messageBubbleTableView": _privateChatVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageBubbleTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messageBubbleTableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}

- (void)setUpBlock{
    __weak typeof(self) weakSelf = self;
    
    _privateChatVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}

#pragma mark --- 发送内容
- (void)sendContent{
    [self.editingBar.editView resignFirstResponder];
    
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"私信发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_MESSAGE_PUB]
       parameters:@{
                    @"authorId" : @(_authorId),
                    @"content"  : [Utils convertRichTextToRawText:self.editingBar.editView],
                    
                    }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
}

@end
