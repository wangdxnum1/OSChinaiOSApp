//
//  ImageViewerController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//


// 参考 https://github.com/bogardon/GGFullscreenImageViewController

#import "ImageViewerController.h"
#import "Utils.h"
#import "OSCPhotoAlbumManger.h"

#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface ImageViewerController () <UIScrollViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) BOOL zoomOut;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ImageViewerController

#pragma mark - init method

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    
    return self;
}

- (instancetype)initWithImageURL:(NSURL *)imageURL
{
    self = [self init];
    if (self) {
        _imageURL = imageURL;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [self init];
    if (self) {
        _image = image;
    }
    
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configureScrollView];
    [self configureImageView];
    
    if (_image) {
        _imageView.image = _image;
        _imageView.frame = [self frameForImage:_image];
        _scrollView.contentSize = [self contentSizeForImage:_image];
    } else {
        if (![[SDWebImageManager sharedManager] cachedImageExistsForURL:_imageURL]) {
            _HUD = [Utils createHUD];
            _HUD.mode = MBProgressHUDModeAnnularDeterminate;
            [_HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)]];
        }
        
        [_imageView sd_setImageWithURL:_imageURL
                      placeholderImage:nil
                               options:SDWebImageProgressiveDownload | SDWebImageContinueInBackground
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  _HUD.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (image) {
                                     [_HUD hideAnimated:YES];
                                     
                                     _imageView.frame = [self frameForImage:image];
                                     _scrollView.contentSize = [self contentSizeForImage:image];
                                 } else {
                                     _HUD.label.text = @"图片无法加载";
                                     [_HUD hideAnimated:YES afterDelay:1.0];
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }
                                 
                             }];
    }
    
    _saveButton = [UIButton new];
    CGFloat X = self.view.frame.size.width;
    CGFloat Y = self.view.frame.size.height;
    _saveButton.frame = CGRectMake(X-60, Y-60, 30, 30);
    [_saveButton setImage:[UIImage imageNamed:@"btn_download"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(downloadPicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
}

- (void)configureScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 2;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
//    panGestureRecognizer.delegate = self;
//    [_scrollView addGestureRecognizer:panGestureRecognizer];
}

- (void)configureImageView
{
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
//    [_imageView addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:singleTap];
}

- (CGSize)contentSizeForImage:(UIImage *)image
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat contentHeight = screenWidth * image.size.height / image.size.width;
    return CGSizeMake(screenWidth, contentHeight);
}

- (CGRect)frameForImage:(UIImage *)image
{
//    if (!image) {return CGRectZero;}
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat imageHeight = width / image.size.width * image.size.height;
    CGFloat y = imageHeight > screenHeight ? 0 : (screenHeight - imageHeight) / 2;
    
    return CGRectMake(0, y, width, imageHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

// http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.bounds.size.width > scrollView.contentSize.width ?
                      (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
    
    CGFloat offsetY = scrollView.bounds.size.height > scrollView.contentSize.height ?
                      (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,
                                    scrollView.contentSize.height / 2 + offsetY);
}

#pragma mark - handle gesture

- (void)handleSingleTap
{
    [_HUD hideAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    CGFloat power = _zoomOut ? 1/_scrollView.maximumZoomScale : _scrollView.maximumZoomScale;
    _zoomOut = !_zoomOut;
    
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = _scrollView.zoomScale * power;
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

// from https://github.com/ideaismobile/IDMPhotoBrowser

- (void)panGestureRecognized:(id)sender
{
    CGFloat bottomOffset = _scrollView.contentSize.height - _scrollView.bounds.size.height;
    BOOL isInContentRegion = _scrollView.contentOffset.y > 0 && _scrollView.contentOffset.y < bottomOffset;
    
    if (isInContentRegion || _zoomOut) {
        return;
    }
    
    static float firstX, firstY;
    
    float viewHeight = _scrollView.frame.size.height;
    float viewHalfHeight = viewHeight / 2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
    
    if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
        firstX = _scrollView.center.x;
        firstY = _scrollView.center.y;
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY + translatedPoint.y);
    [_scrollView setCenter:translatedPoint];
    
    float newY = _scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY) / viewHeight;
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (_scrollView.center.y > viewHalfHeight + 100 || _scrollView.center.y < viewHalfHeight - 100) { // Automatic Dismiss View
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = self.view.frame.size.height;
            
            if (_scrollView.center.y > viewHalfHeight + 30) { // swipe down
                finalY = windowsHeigt * 2;
            } else { // swipe up
                finalY = -viewHalfHeight;
            }
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [_scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            [UIView commitAnimations];
            
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } else { // Continue Showing View
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (0.35 * [(UIPanGestureRecognizer *)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY) * 0.0002) + 0.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [_scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//下载保存图片
- (void)downloadPicture
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下载图片至手机相册" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        MBProgressHUD *HUD = [Utils createHUD];
        
        OSCPhotoAlbumManger* manger = [OSCPhotoAlbumManger sharePhotoAlbumManger];
        if (self.imageView.image) {
            [manger saveImage:self.imageView.image albumName:@"OSChina" completeHandle:^(NSError *error, BOOL isHasAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    HUD.mode = MBProgressHUDModeCustomView;
                    if (isHasAuthorized) {
                        if (error) {
                            HUD.label.text = @"保存失败";
                        }else{
                            HUD.label.text = @"保存成功";
                        }
                    }else{
                        HUD.label.text = @"授权失败";
                    }
                    [HUD hideAnimated:YES afterDelay:1];
                });
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.label.text = @"保存出错";
                [HUD hideAnimated:YES afterDelay:1];
            });
        }
//        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
}

//- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    MBProgressHUD *HUD = [Utils createHUD];
//    HUD.mode = MBProgressHUDModeCustomView;
//    
//    if (!error) {
//        HUD.label.text = @"保存成功";
//    } else {
//        HUD.label.text = [NSString stringWithFormat:@"%@", [error description]];
//    }
//    
//    [HUD hideAnimated:YES afterDelay:1];
//}

@end
