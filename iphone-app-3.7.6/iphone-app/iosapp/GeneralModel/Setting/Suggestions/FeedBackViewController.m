//
//  FeedBackViewController.m
//  iosapp
//
//  Created by 李萍 on 16/1/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "FeedBackViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "AppDelegate.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>

@interface FeedBackViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *stringType;
@property (nonatomic, strong) UIImage *image;

@end

@implementation FeedBackViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendFeedback)];
    
    [self setLayout];
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [_feedbackTextView.rac_textSignal map:^(NSString *feedback) {
        return @(feedback.length > 0);
    }];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    _stringType = @"程序错误";
    
    self.printscrenImagView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeprintscreen)];
    [self.printscrenImagView addGestureRecognizer:tap1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hideAnimated:YES];
    [super viewWillDisappear:animated];
}

- (void)setLayout
{
    _feedbackTextView.placeholder = @"请提出您的意见与建议";
    _feedbackTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_feedbackTextView];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        _feedbackTextView.backgroundColor = [UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1.0];
        _feedbackTextView.textColor = [UIColor titleColor];
    }
}

#pragma mark - 选择意见类型

- (IBAction)selectedFeedBackType:(UIButton *)sender {
    if (sender.tag == 1) {
        [_programErrorView setImage:[UIImage imageNamed:@"feedback_selected"] forState:UIControlStateNormal];
        [_recommentFunctionView setImage:[UIImage imageNamed:@"feedback_unSelected"] forState:UIControlStateNormal];
        _stringType = @"程序错误";
    } else if (sender.tag == 2) {
        [_programErrorView setImage:[UIImage imageNamed:@"feedback_unSelected"] forState:UIControlStateNormal];
        [_recommentFunctionView setImage:[UIImage imageNamed:@"feedback_selected"] forState:UIControlStateNormal];
        _stringType = @"功能建议";
    }
}

#pragma mark - 选择截图
- (void)takeprintscreen
{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        _printscrenImagView.image = _image;
    }];
}

#pragma mark - 隐藏软键盘
- (void)HideKeyBoard
{
    [_feedbackTextView resignFirstResponder];
}

#pragma mark - 发送反馈信息

- (void)sendFeedback
{
    _HUD = [Utils createHUD];
    _HUD.label.text = @"正在发送反馈";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_MESSAGE_PUB]
       parameters:@{
                    @"uid"      : @([Config getOwnID]),
                    @"receiver" : @(2609904),
                    @"content"  : [NSString stringWithFormat:@"[iOS-主站-%@]\n%@", _stringType, _feedbackTextView.text]
                    }
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (_image) {
                [formData appendPartWithFileData:[Utils compressImage:_image]
                                            name:@"file"
                                        fileName:@"img.jpg"
                                        mimeType:@"image/jpeg"];
            }
        } success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
            ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
            int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
            NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
            
            if (errorCode == 1) {
                [_HUD hideAnimated:YES];
                _HUD.mode = MBProgressHUDModeCustomView;
                _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                _HUD.label.text = @"发送成功，感谢您的反馈";
                [_HUD hideAnimated:YES afterDelay:2];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                _HUD.mode = MBProgressHUDModeCustomView;
                _HUD.label.text = errorMessage;
                [_HUD hideAnimated:YES afterDelay:1];
            }
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            _HUD.mode = MBProgressHUDModeCustomView;
//            _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
            _HUD.label.text = @"网络异常，发送失败";
            [_HUD hideAnimated:YES afterDelay:1.0];
        }];
    
}


@end
