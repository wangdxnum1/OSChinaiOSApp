//
//  VoiceTweetEditingVC.m
//  iosapp
//
//  Created by 李萍 on 15/4/27.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "VoiceTweetEditingVC.h"
#import "PlaceholderTextView.h"
#import "Utils.h"
#import "Config.h"
#import "LoginViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import "OSCAPI.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceTweetEditingVC () <UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) PlaceholderTextView   *edittingArea;
@property (nonatomic, strong) UILabel *tweetTextLabel;
@property (nonatomic, strong) UIImageView *voiceImageView;
@property (nonatomic, strong) UILabel *voiceTimes;

@property (nonatomic, strong) UILabel *timesLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) NSURL *recordingUrl;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int recordTime;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL hasVoice;
@property (nonatomic, assign) int recordNumber;

@property (nonatomic, assign) int playDuration;
@property (nonatomic, assign) int playTimes;


@end

@implementation VoiceTweetEditingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"弹一弹";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelEditing)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pubTweet)];
    self.navigationItem.rightBarButtonItem.enabled = _hasVoice;
    self.view.backgroundColor = [UIColor themeColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=YES;
    [self initSubViews];
    [self setLayout];
    
    [self prepareForAudio];
    
    _recordNumber = 1;
}

- (void)initSubViews
{
    _edittingArea = [PlaceholderTextView new];
    _edittingArea.placeholder = @"为你的声音附上一段描述...";
    _edittingArea.delegate = self;
    _edittingArea.returnKeyType = UIReturnKeySend;
    _edittingArea.scrollEnabled = NO;
    _edittingArea.font = [UIFont systemFontOfSize:16];
    _edittingArea.autocorrectionType = UITextAutocorrectionTypeNo;
    //边框设置
    _edittingArea.layer.borderColor = UIColor.grayColor.CGColor;
    _edittingArea.layer.borderWidth = 2;
    [self.view addSubview:_edittingArea];
    
    _edittingArea.backgroundColor = [UIColor themeColor];
    _edittingArea.textColor = [UIColor titleColor];
    
    _voiceImageView = [UIImageView new];
    _voiceImageView.image = [UIImage imageNamed:@"voice_0.png"];
    [self.view addSubview:_voiceImageView];
    
    //添加图片
    NSMutableArray *PicArray = [NSMutableArray new];
    for (int nums = 1; nums < 4; nums++) {//四张图片
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_%d.png", nums]];
        
        [PicArray addObject:image];
    }
    _voiceImageView.animationImages = PicArray;
    _voiceImageView.animationDuration = 1;//一次完整动画的时长
    _voiceImageView.hidden = YES;
    _voiceImageView.userInteractionEnabled = YES;
    
    //添加录音图片点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PlayVoice)];
    [_voiceImageView addGestureRecognizer:tapGesture];
    
    _voiceTimes = [UILabel new];
    [_voiceTimes setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_voiceTimes];
    
    
    _timesLabel = [UILabel new];
    _timesLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timesLabel];
    
    _playButton = [UIButton new];
    [_playButton setImage:[UIImage imageNamed:@"voice_play.png"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(PlayVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    _recordingButton = [UIButton new];
    [_recordingButton setImage:[UIImage imageNamed:@"voice_record.png"] forState:UIControlStateNormal];
    [self.view addSubview:_recordingButton];
    
    [_recordingButton addTarget:self action:@selector(StartRecordingVoice) forControlEvents:UIControlEventTouchDown];
    [_recordingButton addTarget:self action:@selector(StopRecordingVoice) forControlEvents:UIControlEventTouchUpInside];
    [_recordingButton addTarget:self action:@selector(StopRecordingVoice) forControlEvents:UIControlEventTouchUpOutside];
    
    
    _deleteButton = [UIButton new];
    [_deleteButton setImage:[UIImage imageNamed:@"voice_delete.png"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(DeleteVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteButton];
    
    _textLabel = [UILabel new];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.text = @"长按  录音";
    [self.view addSubview:_textLabel];
    _textLabel.textColor = [UIColor titleColor];
}

- (void)setLayout
{
    for (UIView *view in self.view.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(_edittingArea, _voiceImageView, _voiceTimes, _timesLabel, _playButton, _recordingButton, _deleteButton, _textLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_edittingArea(100)]-8-[_voiceImageView(30)]->=5-[_timesLabel]"
                                                                      options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_edittingArea]-10-|"
                                                                      options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_voiceImageView(90)]-10-[_voiceTimes]-10-|"
                                                                      options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timesLabel]-10-[_recordingButton(100)]-8-[_textLabel]-10-|"
                                                                      options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_timesLabel]-10-|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_playButton(50)]"
                                                                      options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_deleteButton(50)]"
                                                                      options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[_playButton(50)]->=25-[_recordingButton(100)]->=25-[_deleteButton(50)]-30-|"
                                                                      options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_textLabel]-10-|" options:0 metrics:nil views:views]];
    
}

- (void)prepareForAudio
{
    _audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"audioSession:%@ %d %@", [error domain], (int)[error code], [[error userInfo] description]);
        return;
    }
    [_audioSession setActive:YES error:&error];
    error = nil;
    if (error) {
        NSLog(@"audioSession:%@ %d %@", [error domain], (int)[error code], [[error userInfo] description]);
        return;
    }
    
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey, nil];
    
    _recordingUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.wav"]];

    error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordingUrl settings:recordSetting error:&error];
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;
}

#pragma mark- 长按 开始录音
- (void)StartRecordingVoice
{
    //判断是否是第一次录制
    if (_recordNumber > 1) {
        [self recordAgain];
    }
    
    _audioSession = [AVAudioSession sharedInstance];
    
    if (!_audioRecorder.recording) {
        
        _recordNumber++;
        
        _hasVoice = YES;
        self.navigationItem.rightBarButtonItem.enabled = _hasVoice;
        _timesLabel.hidden = NO;
        _textLabel.text = @"放开  停止";
        
        [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [_audioSession setActive:YES error:nil];
        
        [_audioRecorder prepareToRecord];
        [_audioRecorder peakPowerForChannel:0.0];
        [_audioRecorder record];
        
        _recordTime = 0;
        
        [self recordTimeStart];
    }
}

#pragma mark - 录音时间
- (void)recordTimeStart
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimesTick) userInfo:nil repeats:YES];
}

- (void)recordTimesTick
{
    _recordTime += 1;
    if (_recordTime == 30) {
        _recordTime = 0;
        [_audioRecorder stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        [_timer invalidate];
        _timesLabel.text = @"00:00";
        
        return;
    }
    [self updateRecordTime];
}
- (void)updateRecordTime
{
    _minute = _recordTime/60.0;
    _second = _recordTime - _minute * 60;
    
    _timesLabel.text = [NSString stringWithFormat:@"%02d:%02d", _minute, _second];
}

#pragma mark- 放开长按 停止录音
- (void)StopRecordingVoice
{
    _audioSession = [AVAudioSession sharedInstance];
    
    if (_audioRecorder.isRecording) {
        int seconds = _minute*60 + _second;
        _voiceTimes.text = [NSString stringWithFormat:@"%d\" ",seconds];
        
        _voiceImageView.hidden = NO;
        _voiceTimes.hidden = NO;
        _textLabel.text = @"长按  录音";
        
        [_audioRecorder stop];
        [_audioSession setActive:NO error:nil];
        [_timer invalidate];
        
        [self updateRecordTime];
    }
}

#pragma mark - 播放录音
- (void)PlayVoice
{
    if (_hasVoice) {
        _audioSession = [AVAudioSession sharedInstance];
        
        if (_isPlay) {
            [_playButton setImage:[UIImage imageNamed:@"voice_play.png"] forState:UIControlStateNormal];
            _isPlay = NO;
            
            [_voiceImageView stopAnimating];
            
            [_audioPlayer pause];
            [_audioSession setActive:NO error:nil];
        } else {
            _voiceImageView.hidden = NO;
            _voiceTimes.hidden = NO;
            [_voiceImageView startAnimating];
            
            [_playButton setImage:[UIImage imageNamed:@"voice_pause.png"] forState:UIControlStateNormal];
            _isPlay = YES;
            
            [_audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [_audioSession setActive:YES error:nil];
            
            NSError *error = nil;
            if (_recordingUrl != nil) {
                _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordingUrl error:&error];
            }
            if (error) {
                NSLog(@"error:%@", [error description]);
            }
            
            [_audioPlayer prepareToPlay];
            _audioPlayer.volume = 1;
            [_audioPlayer play];
            
            //播放时间
            _playDuration = (int)_audioPlayer.duration;
            _playTimes = 0;
            [self audioPlayTimesStart];
        }

    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"没有语音信息可播";
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD hideAnimated:YES afterDelay:1];
    }
    
}

#pragma mark - 播放录音时间

- (void)audioPlayTimesStart
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playTimeTick) userInfo:nil repeats:YES];
}

- (void)playTimeTick
{
    //当播放时长等于音频时长时，停止跳动。
    if (_playDuration == _playTimes) {
        
        _isPlay = NO;
        [_playButton setImage:[UIImage imageNamed:@"voice_play.png"] forState:UIControlStateNormal];
        [_voiceImageView stopAnimating];
        
        
        _playTimes = 0;
        [_audioPlayer stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        [_timer invalidate];
        return;
    }
    if (!_audioPlayer.isPlaying) {
        return;
    }
    _playTimes += 1;
}

- (void)recordAgain
{
    [_audioPlayer stop];
    [_audioRecorder stop];
    [_audioSession setActive:NO error:nil];
    
    [_timer invalidate];
    _recordTime = 0;
    _playTimes = 0;
}

#pragma mark - 删除录音
- (void)DeleteVoice
{
    if (_hasVoice) {
        _audioSession = [AVAudioSession sharedInstance];
        
        _hasVoice = NO;
        self.navigationItem.rightBarButtonItem.enabled = _hasVoice;
        
        [_audioPlayer stop];
        _isPlay = NO;
        [_playButton setImage:[UIImage imageNamed:@"voice_play"] forState:UIControlStateNormal];
        [_voiceImageView stopAnimating];
        
        [_audioRecorder stop];
        
        [_audioSession setActive:NO error:nil];
        
        [_timer invalidate];
        [_audioRecorder deleteRecording];
        
        _voiceImageView.hidden = YES;
        _voiceTimes.hidden = YES;
        _timesLabel.text = @"00:00";
    }
    
}

#pragma mark - 取消发送动弹

- (void)cancelEditing
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 发送语音动弹

- (void)pubTweet
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    if (!_hasVoice) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"还没有语音，请录音";
        [HUD hideAnimated:YES afterDelay:1];
        return;
    }
    NSString *message;
    if ([Utils convertRichTextToRawText:_edittingArea].length) {
        message = [Utils convertRichTextToRawText:_edittingArea];
    } else {
        message = @"#语音动弹#";
    }
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"语音动弹发送中";
    HUD.removeFromSuperViewOnHide = NO;
    [HUD hideAnimated:YES afterDelay:1];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_PUB]
             parameters:@{
                          @"uid": @([Config getOwnID]),
                          @"msg": message
                          }
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         
         if (_recordingUrl.absoluteString.length) {
             
             NSError *error = nil;
             
             NSString *voicePath = [NSString stringWithFormat:@"%@selfRecord.wav", NSTemporaryDirectory()];
             
             [formData appendPartWithFileURL:[NSURL fileURLWithPath:voicePath isDirectory:NO]
                                        name:@"amr"
                                    fileName:@"selfRecord.wav"
                                    mimeType:@"audio/mpeg"
                                       error:&error];
             
         }
     }
     success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
         ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
         int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
         NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
         
         HUD.mode = MBProgressHUDModeCustomView;
         [HUD showAnimated:YES];
         
         if (errorCode == 1) {
             _edittingArea.text = @"";
             
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
             HUD.label.text = @"动弹发表成功";
         } else {
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
         }
         
         HUD.removeFromSuperViewOnHide = YES;
         [HUD hideAnimated:YES afterDelay:1];
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD.mode = MBProgressHUDModeCustomView;
//        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.label.text = @"网络异常，动弹发送失败";
        
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hideAnimated:YES afterDelay:1];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        [self pubTweet];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - 取消键盘第一响应者
- (void)keyboardHide
{
    [_edittingArea resignFirstResponder];
}


@end
