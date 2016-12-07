//
//  OSCFunctionIntroManager.m
//  iosapp
//
//  Created by Graphic-one on 16/11/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCFunctionIntroManager.h"

@implementation OSCFunctionIntroManager

+ (OSCIntroView* )showIntroPage{
    if ([self isNeedShowIntroPage]) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        OSCIntroView* introView = [[OSCIntroView alloc] initWithFrame:keyWindow.bounds];
        [introView animation];
        [keyWindow addSubview:introView];
        return introView;
    }
    return nil;
}

+ (BOOL)isNeedShowIntroPage{
    NSString* appVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaults_AppVersion];
    NSString* curAppVersion = Application_Version;
    return ![appVersion isEqualToString:curAppVersion] ;
}


@end




#define kscreen_width [UIScreen mainScreen].bounds.size.width
#define right_padding 2
#define layer_size 36
#define topbar_height 64
#define whitePoint_topPadding 10
#define PI 3.14159265358979323846

@interface OSCIntroView ()
@property (nonatomic,strong) NSArray<UIImageView* >* rounds;
@end

@implementation OSCIntroView{
    CGPoint _centerPoint , _whitePoint;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:({
            UIView* bg_View = [[UIView alloc]initWithFrame:self.bounds];
            bg_View.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            bg_View;
        })];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:({
            btn.frame = (CGRect){{kscreen_width - right_padding - layer_size , topbar_height},{layer_size,layer_size}};
            btn.backgroundColor = [UIColor whiteColor];
            [btn setImage:[UIImage imageNamed:@"ic_subscribe"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(openSelector) forControlEvents:UIControlEventTouchUpInside];
//            btn.imageView.center = btn.center;
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = layer_size * 0.5;
            _centerPoint = btn.center;
            btn;
        })];
        
        [self addSubview:({
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_subscribe"]];
            imageView.frame = (CGRect){{kscreen_width - right_padding - layer_size - 90,topbar_height + 50},{106,95}};
            imageView;
        })];
        
        [self addSubview:({
            CGFloat x = (CGRectGetMidX(btn.frame) + layer_size * 0.5) - 1;
            CGFloat y = (CGRectGetMaxY(btn.frame) + whitePoint_topPadding) - 1;
            UIView* point = [[UIView alloc]initWithFrame:(CGRect){{x,y},{1,1}}];
            point.backgroundColor = [UIColor whiteColor];
            point.layer.masksToBounds = YES;
            point.layer.cornerRadius = 1 * 0.5;
            _whitePoint = point.center;
            point;
        })];
        
        UIImage* roundImage = [self getRound:9.0];
        
        NSMutableArray<UIImageView* >* mutableArray = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:roundImage];
            imageView.contentMode =  UIViewContentModeCenter;
            imageView.frame = (CGRect){{0,0},{11,11}};
            imageView.center = btn.center;
            [self addSubview:imageView];
            [mutableArray addObject:imageView];
        }
        _rounds = mutableArray.copy;
        
    }
    return self;
}

- (void)openSelector{
    if (_didClickAddButtonBlock) {
        _didClickAddButtonBlock();
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[NSUserDefaults standardUserDefaults] setValue:Application_Version forKey:kUserDefaults_AppVersion];
}

- (void)animation{
    NSInteger index = 0;
    for (UIImageView* imageView in self.rounds) {
        imageView.transform = CGAffineTransformMakeScale(1, 1);
        imageView.alpha = 0.99f;
        
        [self _animation:imageView animationDuration:3.5 delay:index + 0.22];
        
        index ++;
    }
}
- (void)_animation:(UIView* )view
 animationDuration:(NSTimeInterval)duration
             delay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        view.transform = CGAffineTransformMakeScale(6.5,6.5);
        view.alpha = 0.01f;
        
    } completion:^(BOOL finished) {
        view.transform = CGAffineTransformMakeScale(1, 1);
        view.alpha = 0.99f;
        
        [self _animation:view animationDuration:duration delay:delay];
    }];
}


#pragma mark - touch 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[NSUserDefaults standardUserDefaults] setValue:Application_Version forKey:kUserDefaults_AppVersion];
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[NSUserDefaults standardUserDefaults] setValue:Application_Version forKey:kUserDefaults_AppVersion];
    [super touchesCancelled:touches withEvent:event];
}


#pragma mark - Get round
- (UIImage* )getRound:(CGFloat)radius{
    UIImage* image ;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2 , radius * 2), NO, 0);
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, radius * 2 - 2, radius * 2 - 2)];
    [p setLineWidth:0.2f];
    [[UIColor clearColor] setFill];
    [[UIColor whiteColor] setStroke];
    [p stroke];
    [p fill];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
