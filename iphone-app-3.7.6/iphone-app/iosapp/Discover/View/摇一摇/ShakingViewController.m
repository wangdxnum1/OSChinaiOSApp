//
//  ShakingViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ShakingViewController.h"
#import "OSCRandomMessage.h"
#import "RandomMessageCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "DetailsViewController.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCSoftware.h"
#import "OSCModelHandler.h"
#import "OSCRandomDefaultView.h"
#import "OSCPushTypeControllerHelper.h"
#import "UINavigationController+Router.h"
#import "OSCMotionManager.h"

#import <CoreMotion/CoreMotion.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <AudioToolbox/AudioToolbox.h>

#define SHAKING_VIEW_W (self.view.bounds.size.width - 60)
#define SHAKING_VIEW_H 80
#define SHAKING_VIEW_SIZE (CGSize){SHAKING_VIEW_W,SHAKING_VIEW_H}

#define OFFEST_H 130

static const double accelerationThreshold = 2.0f;

@interface ShakingViewController ()<OSCRandomDefaultViewDelegate>

@property (nonatomic, strong) OSCRandomMessageItem *randomMessage;
@property (nonatomic, strong) UIImageView *layer;
@property (nonatomic, strong) OSCRandomDefaultView* randomDefaultView;
@property CMMotionManager *motionManager;
@property NSOperationQueue *operationQueue;

@end

@implementation ShakingViewController{
    SystemSoundID soundID;
}

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
    
    self.navigationItem.title = @"摇一摇";
    self.view.backgroundColor = [UIColor colorWithHex:0xEFEFF4];
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    }
    
    [self setLayout];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    
    _motionManager = [OSCMotionManager shareMotionManager];
    _motionManager.accelerometerUpdateInterval = 0.1;
    _operationQueue = [NSOperationQueue new];
}

- (void)backButtonClick
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startAccelerometer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_motionManager stopAccelerometerUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [super viewDidDisappear:animated];
}



#pragma mark - 视图布局

- (void)setLayout
{    
    _layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_shake"]];
    _layer.size = (CGSize){100,140};
    _layer.centerX = self.view.centerX;
    _layer.centerY = self.view.centerY - 100;
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    _randomDefaultView = [[OSCRandomDefaultView alloc]init];
    _randomDefaultView.left = self.view.bounds.size.width * 0.5 - SHAKING_VIEW_W * 0.5;
    _randomDefaultView.top = self.view.bottom;
    _randomDefaultView.size = SHAKING_VIEW_SIZE;
    _randomDefaultView.hidden = YES;
    _randomDefaultView.delegate = self;
    [self.view addSubview:_randomDefaultView];
}

#pragma mark - OSCRandomDefaultViewDelegate
- (void)randomDefaultViewDidClickDefaultView:(OSCRandomDefaultView *)randomDefaultView{
    if (!randomDefaultView.randomMessageItem) { return; }
    
    UIViewController* pushController = [OSCPushTypeControllerHelper pushControllerWithRandomNewsType:_randomMessage];
    if (pushController) {
        [self.navigationController pushViewController:pushController animated:YES];
    }else{
        [self.navigationController handleURL:[NSURL URLWithString:_randomMessage.href] name:nil];
    }
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_layer];
}


#pragma mark - 监听动作

-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             [self outputAccelertionData:accelerometerData.acceleration];
                                         }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    double accelerameter = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    
    if (accelerameter > accelerationThreshold) {
        [_motionManager stopAccelerometerUpdates];
        [_operationQueue cancelAllOperations];
        if (_isShaking) {return;}
        _isShaking = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rotate:_layer];
            //[self getRandomMessage];
        });
    }
}

-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_motionManager stopAccelerometerUpdates];
    } else {
        [self startAccelerometer];
    }
}



#pragma mark - 动画效果

- (void)rotate:(UIView *)view
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat: - M_PI / 7.0];
    rotate.duration = 0.18;
    rotate.repeatCount = 2;
    rotate.autoreverses = YES;
    
    [CATransaction begin];
    [self setAnchorPoint:CGPointMake(1.3, 1.3) forView:view];
    [CATransaction setCompletionBlock:^{
        [self getRandomMessage];
    }];
    [view.layer addAnimation:rotate forKey:nil];
    [CATransaction commit];
}


// 参考 http://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}



#pragma mark - 获取数据

- (void)getRandomMessage
{
    _isShaking = YES;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_RANDOM_SHAKING_NEW]
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 _randomMessage = [[NSArray osc_modelArrayWithClass:[OSCRandomMessageItem class] json:@[resultDic]] lastObject];
                 if (_randomMessage) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (_randomDefaultView.isHidden) {
                             _randomDefaultView.randomMessageItem = _randomMessage;
                             _randomDefaultView.hidden = NO;
                             _randomDefaultView.alpha = 0.1;
                             AudioServicesPlaySystemSound(soundID);
                             [UIView animateWithDuration:0.5 animations:^{
                                 _randomDefaultView.alpha = 0.99;
                                 _randomDefaultView.top = self.view.bounds.size.height - OFFEST_H;
                             } completion:^(BOOL finished) {
                                 _randomDefaultView.alpha = 1;
                                 _randomDefaultView.top = self.view.bounds.size.height - OFFEST_H;
                                 
                                 [self startAccelerometer];
                                 _isShaking = NO;
                             }];
                         }else{
                             AudioServicesPlaySystemSound(soundID);
                             [UIView animateWithDuration:0.2 animations:^{
                                 _randomDefaultView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             } completion:^(BOOL finished) {
                                 _randomDefaultView.randomMessageItem = _randomMessage;
                                 _randomDefaultView.transform = CGAffineTransformMakeScale(1, 1);
                                 _randomDefaultView.top = self.view.bottom;
                                 [UIView animateWithDuration:0.5 animations:^{
                                     _randomDefaultView.alpha = 0.99;
                                     _randomDefaultView.top = self.view.bounds.size.height - OFFEST_H;
                                 } completion:^(BOOL finished) {
                                     _randomDefaultView.alpha = 1;
                                     _randomDefaultView.top = self.view.bounds.size.height - OFFEST_H;
                                     
                                     [self startAccelerometer];
                                     _isShaking = NO;
                                 }];
                             }];
                         }

                     });
                 }
             }else{
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = [NSString stringWithFormat:@"%@",responseObject[@"message"]];
                 [HUD hideAnimated:YES afterDelay:2];
                 [self startAccelerometer];
                 _isShaking = NO;
             }
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，请检测网络";
             
             [HUD hideAnimated:YES afterDelay:2];
             
             [self startAccelerometer];
             _isShaking = NO;
    }];
}




@end
