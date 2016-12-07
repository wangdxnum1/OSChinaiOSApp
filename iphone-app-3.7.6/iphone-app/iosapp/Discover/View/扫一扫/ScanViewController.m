//
//  ScanViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ScanViewController.h"
#import "Utils.h"
#import "Config.h"
#import "UIView+Common.h"

#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, copy) NSString *webURL;

@end

@implementation ScanViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus != AVAuthorizationStatusRestricted && authStatus != AVAuthorizationStatusDenied){
        [self setUpCamera];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [self.view showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_fail"] tipString:@"未获得相机权限"];
        return;
    }
    
    [self setScanRegion];
    [_session startRunning];
}

- (void)cancelButtonClicked
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpCamera
{
    _device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input   = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _output  = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [AVCaptureSession new];
    [_session addInput:_input];
    [_session addOutput:_output];
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_preview setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_preview];
}

- (void)setScanRegion
{
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
    overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:overlayImageView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view        attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:overlayImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view        attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:overlayImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;

//	_output.rectOfInterest = CGRectMake((screenHeight - 200) / 2 / screenHeight,
//										(screenWidth  - 260) / 2 / screenWidth,
//										200 / screenHeight,
//										260 / screenWidth);
	
    _output.rectOfInterest = CGRectMake((screenHeight - 400) / 2 / screenHeight,
                                        (screenWidth  - 460) / 2 / screenWidth,
                                        400 / screenHeight,
                                        460 / screenWidth);
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	
    NSString *message;
    
    if (metadataObjects.count > 0) {
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        
        message = metadataObject.stringValue;
        
        if ([message rangeOfString:@"scan_login"].location != NSNotFound) {
            [self loginInWithURL:message];
        } else if ([message hasPrefix:@"{"]) {
            [self signInWithJson:message];
        } else if ([Utils isURL:message]) {
            [self.navigationController handleURL:[NSURL URLWithString:message] name:nil];
        } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeText;
            HUD.detailsLabel.text = message;
            
            [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
            [HUD hideAnimated:YES afterDelay:2];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}



#pragma mark - 处理扫描结果

- (void)signInWithJson:(NSString *)jsonString
{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.label.text = @"您还没登录，请先登录再扫描签到";
        
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
        [HUD hideAnimated:YES afterDelay:2];
    } else {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSNumber *requireLogin = json[@"require_login"];
        NSString *title = json[@"title"];
        NSNumber *type = json[@"type"];
        NSString *URL = json[@"url"];
        
        if (!requireLogin || !title || !type || !URL) {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
            HUD.label.text = @"无效二维码";
            
            [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
            [HUD hideAnimated:YES afterDelay:2];
        } else {
            if ([type intValue] != 1) {
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeText;
                HUD.label.text = title;
                
                [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                [HUD hideAnimated:YES afterDelay:2];
            } else {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
                
                [manager GET:URL
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                         MBProgressHUD *HUD = [Utils createHUD];
                         HUD.mode = MBProgressHUDModeCustomView;
                         
                         NSString *message = responseObject[@"msg"];
                         NSString *error   = responseObject[@"error"];
                         
                         if (message) {
                             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                             HUD.label.text = message;
                         } else if ([error isEqualToString:@"你已签到成功:)"]) { // 重复签到
                             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                             HUD.label.text = error;
                         } else {
                             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                             HUD.label.text = error;
                         }
                         
                         [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                         [HUD hideAnimated:YES afterDelay:2];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         MBProgressHUD *HUD = [Utils createHUD];
                         HUD.mode = MBProgressHUDModeCustomView;
//                         HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                         HUD.label.text = @"网络连接故障";
                         
                         [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                         [HUD hideAnimated:YES afterDelay:2];
                     }];
            }
        }
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)loginInWithURL:(NSString *)URL
{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.label.text = @"您还没登录，请先登录再扫描";
        
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
        [HUD hideAnimated:YES afterDelay:2];
        
        return;
    }
    
    _webURL = URL;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描成功，是否进行网页登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)loginInWeb:(NSString *)webUrl
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:webUrl
             parameters:nil
             success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                    ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
        
                    NSInteger errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] integerValue];
                    NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                 
                    MBProgressHUD *HUD = [Utils createHUD];
                    HUD.mode = MBProgressHUDModeCustomView;
                 
                    if (errorCode == 1) {
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                    } else {
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                    }
                    HUD.label.text = [NSString stringWithFormat:@"%@", errorMessage];
                    [HUD hideAnimated:YES afterDelay:1];
                 
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    MBProgressHUD *HUD = [Utils createHUD];
                    HUD.mode = MBProgressHUDModeCustomView;
//                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                    HUD.label.text = @"网络异常，登录失败";
                    
                    [HUD hideAnimated:YES afterDelay:1];
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    } else {
        [self loginInWeb:_webURL];
    }
}


@end
