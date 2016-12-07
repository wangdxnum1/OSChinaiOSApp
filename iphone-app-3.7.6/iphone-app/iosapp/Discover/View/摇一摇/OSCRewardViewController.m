//
//  OSCRewardViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCRewardViewController.h"
#import "OSCRandomMessage.h"
#import "OSCRandomGiftView.h"
#import "UIDevice+SystemInfo.h"
#import "OSCModelHandler.h"
#import "OSCRandomGiftLargerImageView.h"
#import "BubbleChatViewController.h"
#import "OSCMotionManager.h"

#import "Utils.h"
#import "OSCAPI.h"
#import "Config.h"

#import <CoreMotion/CoreMotion.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <UIView+YYAdd.h>
#import <AudioToolbox/AudioToolbox.h>

#define PRIVATE_KEY @"test" //「密钥」字符串

#define SHAKING_GIFT_VIEW_W (self.view.bounds.size.width - 60)
#define SHAKING_GIFT_VIEW_H 80
#define SHAKING_GIFT_VIEW_SIZE (CGSize){SHAKING_GIFT_VIEW_W,SHAKING_GIFT_VIEW_H}

#define SHAKING_GIFT_LARGER_VIEW_W ((self.view.bounds.size.width) - (40))
#define SHAKING_GIFT_LARGER_VIEW_H 350
#define SHAKING_GIFT_LARGER_SIZE  (CGSize){ SHAKING_GIFT_LARGER_VIEW_W , SHAKING_GIFT_LARGER_VIEW_H }

#define layer_SPACE_textTip 20
#define giftView_SPACE_TimeTip 15
#define OFFEST_H_GIFT 130


static const double accelerationThreshold_gift = 3.0f;

@interface OSCRewardViewController ()<OSCRandomGiftViewDelegate , OSCRandomGiftLargerImageViewDelegate>

@property (nonatomic, strong) OSCRandomGift *randomGift;
@property (nonatomic, strong) UIImageView *layer;
@property (nonatomic, strong) UILabel* textTip;
@property (nonatomic, strong) UILabel* timerTextTip;
@property (nonatomic, strong) OSCRandomGiftView* randomGiftView;
@property (nonatomic, strong) OSCRandomGiftLargerImageView* randomGiftLargerImageView;
@property CMMotionManager *motionManager;
@property NSOperationQueue *operationQueue;

@property (nonatomic,strong) MBProgressHUD* HUD;

@end

@implementation OSCRewardViewController{
    SystemSoundID soundID;
    
    NSTimer* _timeHelper;
    NSString* _msgStr;
    int _successTimeCount;
    int _failureTimeCount;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _successTimeCount = 0;
        _failureTimeCount = 0;
    }
    return self;
}

#pragma mark --- life cycle
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

- (void)viewDidAppear:(BOOL)animated{
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

- (void)viewDidDisappear:(BOOL)animated{
    [_motionManager stopAccelerometerUpdates];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)backButtonClick
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- layoutUI
- (void)setLayout{
    _layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_shake"]];
    _layer.size = (CGSize){100,140};
    _layer.centerX = self.view.centerX;
    _layer.centerY = self.view.centerY - 100;
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    _textTip = [UILabel new];
    _textTip.size = (CGSize){self.view.bounds.size.width , SHAKING_GIFT_VIEW_H };
    _textTip.centerX = self.view.centerX;
    _textTip.top = _layer.bottom - 10;
    _textTip.numberOfLines = 0;
    _textTip.font = [UIFont systemFontOfSize:15];
    _textTip.textColor = [UIColor colorWithHex:0x9d9d9d];
    _textTip.textAlignment = NSTextAlignmentCenter;
    _textTip.text = @"摇一摇可进行搜寻礼品哦";
    _textTip.hidden = NO;
    [self.view addSubview:_textTip];
    
    _timerTextTip = [UILabel new];
    _timerTextTip.size = (CGSize){self.view.bounds.size.width , SHAKING_GIFT_VIEW_H};
    _timerTextTip.centerX = self.view.centerX;
    _timerTextTip.top = _layer.centerY + SHAKING_GIFT_LARGER_VIEW_H * 0.5 + 35;
    _timerTextTip.numberOfLines = 0;
    _timerTextTip.font = [UIFont systemFontOfSize:15];
    _timerTextTip.textColor = [UIColor colorWithHex:0x9d9d9d];
    _timerTextTip.textAlignment = NSTextAlignmentCenter;
    _timerTextTip.text = @" ";
    _timerTextTip.hidden = YES;
    [self.view addSubview:_timerTextTip];
    
//  Larger Gift View
    _randomGiftLargerImageView = [OSCRandomGiftLargerImageView randomGiftLargerImageView];
    _randomGiftLargerImageView.left = self.view.bounds.size.width - 20 - SHAKING_GIFT_LARGER_VIEW_W;
    _randomGiftLargerImageView.centerY = _layer.centerY + 30;
    _randomGiftLargerImageView.size = SHAKING_GIFT_LARGER_SIZE;
    _randomGiftLargerImageView.hidden = YES;
    _randomGiftLargerImageView.delegate = self;
    [self.view addSubview:_randomGiftLargerImageView];
    
//  Nomal Gift View
//    _randomGiftView = [[OSCRandomGiftView alloc]init];
//    _randomGiftView.left = self.view.bounds.size.width * 0.5 - SHAKING_GIFT_VIEW_W * 0.5;
//    _randomGiftView.top = self.view.bottom;
//    _randomGiftView.size = SHAKING_GIFT_VIEW_SIZE;
//    _randomGiftView.hidden = YES;
//    _randomGiftView.delegate = self;
//    [self.view addSubview:_randomGiftView];
}

#pragma mark - 监听动作
-(void)startAccelerometer
{
    if (_successTimeCount == 0 && _failureTimeCount == 0) {
        //以push的方式更新并在block中接收加速度
        [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                             }];
    }
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    double accelerameter = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    
    if (accelerameter > accelerationThreshold_gift) {
        [_motionManager stopAccelerometerUpdates];
        [_operationQueue cancelAllOperations];
        if (_isShaking) {return;}
        _isShaking = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rotate:_layer];
        });
    }
}

#pragma mark - 动画效果
- (void)rotate:(UIView *)view{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat: - M_PI / 8.0];
    rotate.duration = 0.18;
    rotate.repeatCount = 2;
    rotate.autoreverses = YES;
    
    [CATransaction begin];
    [self setAnchorPoint:CGPointMake(1.0, 1.3) forView:view];
    [CATransaction setCompletionBlock:^{
        [self startConductReward];
    }];
    [view.layer addAnimation:rotate forKey:nil];
    [CATransaction commit];
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view{
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

#pragma mark --- Notifacation 
-(void)receiveNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_motionManager stopAccelerometerUpdates];
    } else {
        [self startAccelerometer];
    }
}

#pragma mark --- OSCRandomGiftViewDelegate
- (void)randomGiftViewDidRandomGiftView:(OSCRandomGiftView *)randomGiftView{
    
}

#pragma mark --- OSCRandomGiftLargerImageViewDelegate
- (void)randomGiftLargerImageViewDidClickLeftItem:(OSCRandomGiftLargerImageView *)randomGiftLargerImageView{
    if (!_randomGiftLargerImageView.isHidden) {
        _randomGiftLargerImageView.hidden = YES;
    }
}

- (void)randomGiftLargerImageViewDidClickRightItem:(OSCRandomGiftLargerImageView *)randomGiftLargerImageView{
    [self.navigationController handleURL:[NSURL URLWithString:randomGiftLargerImageView.randomGiftItem.href] name:nil];
//    [self.navigationController pushViewController:[[BubbleChatViewController alloc] initWithUserID:1 andUserName:@"oschina"] animated:YES];
}

#pragma mark --- 发送抽奖request
- (void)startConductReward{
    
/** nomal gift pop view */
//    if (!_randomGiftView.isHidden) {
//        _randomGiftView.hidden = YES;
//        _randomGiftView.top = self.view.bottom;
//    }
    
    _isShaking = YES;

/** larger gift pop view */
    if (!_randomGiftLargerImageView.isHidden) {
        _randomGiftLargerImageView.hidden = YES;
    }
    
    NSMutableDictionary* mutableDic = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSDate *currentDate = [NSDate date];
    NSString *timeString = [formatter stringFromDate:currentDate];
    [mutableDic setObject:@([timeString longValue]) forKey:@"timestamp"];
    
    NSInteger userID = [Config getOwnID];
    [mutableDic setObject:@(userID) forKey:@"userId"];
    
    NSString* bundleInfo = [NSString stringWithFormat:@"%@%@",Application_BundleID,Application_BundleVersion];
//    bundleInfo = @"1";//test AppToken
    [mutableDic setObject:bundleInfo forKey:@"appToken"];

    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray* paraArr = @[timeString,bundleInfo,[NSString stringWithFormat:@"%ld",(long)userID],PRIVATE_KEY];
    NSArray* resultArr = [paraArr sortedArrayUsingDescriptors:@[sortDesc]];
    NSMutableString* mutableStr = @"".mutableCopy;
    for (NSString* resultString in resultArr) {
        [mutableStr appendString:resultString];
    }
    NSString* sha1_String = [Utils sha1:mutableStr.copy];
    [mutableDic setObject:sha1_String forKey:@"signature"];
	
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    _isShaking = YES;
    _timerTextTip.text = @"正在摇取礼物...";
    _textTip.text = @"正在摇取礼物...";	
    
    [manager POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_RANDOM_SHAKING_GIFT]
       parameters:mutableDic.copy
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSLog(@"%@",responseObject);
              if ([responseObject[@"code"] integerValue] == 1) {//活动开始 中奖
                  NSDictionary* resultDic = responseObject[@"result"];
                  
                  _randomGift = [[NSArray osc_modelArrayWithClass:[OSCRandomGift class] json:@[resultDic]] lastObject];
                  
                  if (_randomGift) {//中奖
                      _randomGiftLargerImageView.randomGiftItem = _randomGift;
                      dispatch_async(dispatch_get_main_queue(), ^{
                          _textTip.hidden = YES;
                          _timerTextTip.hidden = NO;
/** larger gift pop view */
                          _randomGiftLargerImageView.hidden = NO;
                          _randomGiftLargerImageView.leftIsAvailable = YES;
                          _randomGiftLargerImageView.rightIsAvailable = YES;
                          _randomGiftLargerImageView.alpha = 0.1;
                          _randomGiftLargerImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                          AudioServicesPlaySystemSound(soundID);
                          [UIView animateWithDuration:0.5 animations:^{
                              _randomGiftLargerImageView.alpha = 0.99;
                              _randomGiftLargerImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                          } completion:^(BOOL finished) {
                              [UIView animateWithDuration:0.2 animations:^{
                                  _randomGiftLargerImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                              } completion:^(BOOL finished) {
                                  _randomGiftLargerImageView.alpha = 1;
                                  _randomGiftLargerImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                  
                                  _successTimeCount = 5;
                                  _timeHelper = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(successTimerHandle) userInfo:nil repeats:YES];
                              }];
                          }];
                          _isShaking = NO;
/** nomal gift pop view */
//                          _randomGiftView.randomGiftItem = _randomGift;
//                          _randomGiftView.hidden = NO;
//                          _randomGiftView.alpha = 0.1;
//                          [UIView animateWithDuration:0.5 animations:^{
//                              _randomGiftView.alpha = 0.99;
//                              _randomGiftView.top = self.view.bounds.size.height - OFFEST_H_GIFT;
//                          } completion:^(BOOL finished) {
//                              _randomGiftView.alpha = 1;
//                              _randomGiftView.top = self.view.bounds.size.height - OFFEST_H_GIFT;
//                              
//                              _successTimeCount = 5;
//                              _timeHelper = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(successTimerHandle) userInfo:nil repeats:YES];
//                          }];
                      });
                  }
              }else if ([responseObject[@"code"] integerValue] == 251) {//活动开始 未中奖
                  dispatch_async(dispatch_get_main_queue(), ^{
                      _textTip.hidden = NO;
                      _timerTextTip.hidden =YES;
/** nomal gift pop view */
//                      if (!_randomGiftView.isHidden) {
//                          _randomGiftView.hidden = YES;
//                          _randomGiftView.top = self.view.bottom;
//                      }
                      
                      /** larger gift pop view */
                      if (!_randomGiftLargerImageView.isHidden) {
                          _randomGiftLargerImageView.hidden = YES;
                      }
                      
                      _failureTimeCount = 5;
                      _timeHelper = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(failureTimerHandle) userInfo:nil repeats:YES];
                  });
                  _isShaking = NO;
              }else{//其他情况
                  NSString* msgStr = responseObject[@"message"];
                  _msgStr = msgStr && msgStr.length > 0 ? msgStr : @"很遗憾,你没有摇到东西.";
                  _textTip.hidden = NO;
                  _timerTextTip.hidden =YES;
                  _textTip.text = _msgStr;
                  [self startAccelerometer];
                  _isShaking = NO;
              }
    }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              _HUD = [Utils createHUD];
              _HUD.mode = MBProgressHUDModeCustomView;
              _HUD.label.text = @"网络异常，请检测网络";
              [_HUD hideAnimated:YES afterDelay:2];
              _timerTextTip.text = @"摇一摇可进行搜寻礼品哦";
              _textTip.text = @"摇一摇可进行搜寻礼品哦";
              [self startAccelerometer];
              _isShaking = NO;
    }];
}

#pragma mark --- timer method
- (void)successTimerHandle{
    if (_successTimeCount > 0) {
        _timerTextTip.text = [NSString stringWithFormat:@"%d秒后可再摇一次",_successTimeCount];
        _successTimeCount -- ;
    }else{
        [_timeHelper invalidate];
        _timerTextTip.text = [NSString stringWithFormat:@"摇一摇可进行搜寻礼品哦"];
        _randomGiftLargerImageView.leftIsAvailable = YES;
        _randomGiftLargerImageView.rightIsAvailable = YES;
        [self startAccelerometer];
    }
}

- (void)failureTimerHandle{
    if (_failureTimeCount > 0) {
        _textTip.text = [NSString stringWithFormat:@"很遗憾，你没有摇到礼物\n请%d秒后再摇一次",_failureTimeCount];
        _failureTimeCount -- ;
    }else{
        [_timeHelper invalidate];
        _textTip.text = [NSString stringWithFormat:@"摇一摇可进行搜寻礼品哦"];
        [self startAccelerometer];
    }
}

@end
