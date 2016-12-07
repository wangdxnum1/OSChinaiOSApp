//
//  OSCTabBarController.m
//  iosapp
//
//  Created by chenhaoxiang on 12/15/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCTabBarController.h"
#import "SwipableViewController.h"
#import "PostsViewController.h"
#import "NewsViewController.h"
#import "HomepageViewController.h"
#import "DiscoverViewcontroller.h"
#import "Config.h"
#import "Utils.h"
#import "OptionButton.h"
#import "TweetEditingVC.h"
#import "UIView+Util.h"
#import "PersonSearchViewController.h"
#import "ScanViewController.h"
#import "ShakingViewController.h"
#import "NewLoginViewController.h"
#import "VoiceTweetEditingVC.h"
#import "OSCActivityViewController.h"
#import "QuesAnsViewController.h"
#import "InformationViewController.h"
#import "NewBlogDetailController.h"
#import "NewBlogsViewController.h"
#import "TweetTableViewController.h"
#import "EventsViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIBarButtonItem+Badge.h"

#import "OSCSearchViewController.h"
#import "OSCSyntheticalController.h"
#import "OSCTweetRecommendCollectionController.h"


@interface OSCTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    TweetTableViewController *newTweetViewCtl;
    TweetTableViewController *hotTweetViewCtl;
    TweetTableViewController *myFriendTweetViewCtl;
//    TweetTableViewController *friendsTweetViewCtl;//好友动弹
    
    OSCTweetRecommendCollectionController *tweetRecommend;
}

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, strong) NSMutableArray *optionButtons;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGGlyph length;

@end

@implementation OSCTabBarController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];
}

- (void)dawnAndNightMode:(NSNotification *)center
{
    newTweetViewCtl.view.backgroundColor = [UIColor themeColor];
    hotTweetViewCtl.view.backgroundColor = [UIColor themeColor];
    myFriendTweetViewCtl.view.backgroundColor = [UIColor themeColor];

    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationbarColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor titleBarColor]];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nav, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            SwipableViewController *newsVc = nav.viewControllers[0];
            [newsVc.titleBar setTitleButtonsColor];
            [newsVc.viewPager.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UITableViewController *table = obj;
                [table.navigationController.navigationBar setBarTintColor:[UIColor navigationbarColor]];
                [table.tabBarController.tabBar setBarTintColor:[UIColor titleBarColor]];
                if([table isKindOfClass:[UITableViewController class]]){
                    [table.tableView reloadData];
                }
                
            }];

        } else if (idx == 1) {
            SwipableViewController *tweetVc = nav.viewControllers[0];
            [tweetVc.titleBar setTitleButtonsColor];
            [tweetVc.viewPager.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UITableViewController *table = obj;
                [table.navigationController.navigationBar setBarTintColor:[UIColor navigationbarColor]];
                [table.tabBarController.tabBar setBarTintColor:[UIColor titleBarColor]];
                [table.tableView reloadData];
            }];

        } else if (idx == 3) {
            DiscoverViewController *dvc = nav.viewControllers[0];
            [dvc.navigationController.navigationBar setBarTintColor:[UIColor navigationbarColor]];
            [dvc.tabBarController.tabBar setBarTintColor:[UIColor titleBarColor]];
            [dvc dawnAndNightMode];
        } else if (idx == 4) {
            HomepageViewController *homepageVC = nav.viewControllers[0];
            [homepageVC.navigationController.navigationBar setBarTintColor:[UIColor navigationbarColor]];
            [homepageVC.tabBarController.tabBar setBarTintColor:[UIColor titleBarColor]];
            [homepageVC dawnAndNightMode];
        }
    }];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dawnAndNight" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    newTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeAllTweets];
    hotTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeHotestTweets];
    myFriendTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeOwnTweets];
    tweetRecommend = [[OSCTweetRecommendCollectionController alloc] init];
    
    OSCSyntheticalController *newsSVC = [[OSCSyntheticalController alloc] init];
    
    SwipableViewController *tweetsSVC = [[SwipableViewController alloc] initWithTitle:@"动弹"
                                                                         andSubTitles:@[@"最新动弹", @"热门动弹", @"我的动弹"]
                                                                       andControllers:@[newTweetViewCtl, hotTweetViewCtl, myFriendTweetViewCtl]
                                                                          underTabbar:YES];
/** 包含推荐话题 */
//    SwipableViewController *tweetsSVC = [[SwipableViewController alloc] initWithTitle:@"动弹"
//                                                                         andSubTitles:@[@"最新动弹", @"热门动弹", @"我的动弹",@"推荐话题"]
//                                                                       andControllers:@[newTweetViewCtl, hotTweetViewCtl, myFriendTweetViewCtl,tweetRecommend]
//                                                                          underTabbar:YES];
    
    
    UIStoryboard *discoverSB = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    UINavigationController *discoverNav = [discoverSB instantiateViewControllerWithIdentifier:@"Nav"];
    
    
    UIStoryboard *homepageSB = [UIStoryboard storyboardWithName:@"Homepage" bundle:nil];
    UINavigationController *homepageNav = [homepageSB instantiateViewControllerWithIdentifier:@"Nav"];
    
    
    self.tabBar.translucent = NO;
    self.viewControllers = @[
                             [self addNavigationItemForViewController:newsSVC],
                             [self addNavigationItemForViewController:tweetsSVC],
                             [UIViewController new],
                             discoverNav,
                             homepageNav,
                             ];
    _linkUtilNavController = [self.viewControllers objectAtIndex:0];
    
    NSArray *titles = @[@"综合", @"动弹", @"", @"发现", @"我的"];
    NSArray *images = @[@"tabbar-news", @"tabbar-tweet", @"", @"tabbar-discover", @"tabbar-me"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitle:titles[idx]];
        item.image = [[UIImage imageNamed:images[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:[images[idx] stringByAppendingString:@"-selected"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    [self.tabBar.items[2] setEnabled:NO];
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"ic_nav_add"]];//@"tabbar-more"]];
    
    [self.tabBar addObserver:self
                  forKeyPath:@"selectedItem"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    
    // 功能键相关
    _optionButtons = [NSMutableArray new];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth  = [UIScreen mainScreen].bounds.size.width;
    _length = 60;        // 圆形按钮的直径
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSArray *buttonTitles = @[@"文字", @"相册", @"拍照", @"语音", @"扫一扫", @"找人"];
    NSArray *buttonImages = @[@"tweetEditing", @"picture", @"shooting", @"sound", @"scan", @"search"];
    int buttonColors[] = {0xe69961, 0x0dac6b, 0x24a0c4, 0xe96360, 0x61b644, 0xf1c50e};
    
    for (int i = 0; i < 6; i++) {
        OptionButton *optionButton = [[OptionButton alloc] initWithTitle:buttonTitles[i]
                                                                   image:[UIImage imageNamed:buttonImages[i]]
                                                                andColor:[UIColor colorWithHex:buttonColors[i]]];
        
        optionButton.frame = CGRectMake((_screenWidth/6 * (i%3*2+1) - (_length+16)/2),
                                        _screenHeight + 150 + i/3*100,
                                        _length + 16,
                                        _length + [UIFont systemFontOfSize:14].lineHeight + 24);
        [optionButton.button setCornerRadius:_length/2];
        
        optionButton.tag = i;
        optionButton.userInteractionEnabled = YES;
        [optionButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOptionButton:)]];
        
        [self.view addSubview:optionButton];
        [_optionButtons addObject:optionButton];
    }
}

- (void)dealloc
{
    [self.tabBar removeObserver:self forKeyPath:@"selectedItem"];
}

-(void)addCenterButtonWithImage:(UIImage *)buttonImage
{
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGPoint origin = [self.view convertPoint:self.tabBar.center toView:self.tabBar];
    CGSize buttonSize = CGSizeMake(self.tabBar.frame.size.width / 5 - 6, self.tabBar.frame.size.height - 4);
    
    _centerButton.frame = CGRectMake(origin.x - buttonSize.height/2, origin.y - buttonSize.height/2, buttonSize.height, buttonSize.height);

    [_centerButton setImage:buttonImage forState:UIControlStateNormal];
    [_centerButton setImage:[UIImage imageNamed:@"ic_nav_add_actived"] forState:UIControlStateHighlighted];
    [_centerButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:_centerButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedItem"]) {
        if(self.isPressed) {[self buttonPressed];}
    }
}


- (void)buttonPressed
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self.selectedViewController presentViewController:loginVC animated:YES completion:nil];
    }else{
        TweetEditingVC *tweetEditingVC = [TweetEditingVC new];
        UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
        [self.selectedViewController presentViewController:tweetEditingNav animated:YES completion:nil];
    }
}


- (void)changeTheButtonStateAnimatedToOpen:(BOOL)isPressed
{
    if (isPressed) {
        [self removeBlurView];
        
        [_animator removeAllBehaviors];
        for (int i = 0; i < 6; i++) {
            UIButton *button = _optionButtons[i];
            
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:button
                                                                         attachedToAnchor:CGPointMake(_screenWidth/6 * (i%3*2+1),
                                                                                                      _screenHeight + 200 + i/3*100)];
            attachment.damping = 0.65;
            attachment.frequency = 4;
            attachment.length = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC * (6 - i)), dispatch_get_main_queue(), ^{
                [_animator addBehavior:attachment];
            });
        }
    } else {
        [self addBlurView];
        
        [_animator removeAllBehaviors];
        for (int i = 0; i < 6; i++) {
            UIButton *button = _optionButtons[i];
            [self.view bringSubviewToFront:button];
            
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:button
                                                                         attachedToAnchor:CGPointMake(_screenWidth/6 * (i%3*2+1),
                                                                                                      _screenHeight - 200 + i/3*100)];
            attachment.damping = 0.65;
            attachment.frequency = 4;
            attachment.length = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC * (i + 1)), dispatch_get_main_queue(), ^{
                [_animator addBehavior:attachment];
            });
        }
    }
}

- (void)addBlurView
{
    _centerButton.enabled = NO;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect cropRect = CGRectMake(0, screenSize.height - 270, screenSize.width, screenSize.height);
    
    UIImage *originalImage = [self.view updateBlur];
    UIImage *croppedBlurImage = [originalImage cropToRect:cropRect];
    
    _blurView = [[UIImageView alloc] initWithImage:croppedBlurImage];
    _blurView.frame = cropRect;
    _blurView.userInteractionEnabled = YES;
    [self.view addSubview:_blurView];
    
    _dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    _dimView.backgroundColor = [UIColor blackColor];
    _dimView.alpha = 0.4;
    [self.view insertSubview:_dimView belowSubview:self.tabBar];
    
    [_blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)]];
    [_dimView  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)]];
    
    [UIView animateWithDuration:0.25f
                     animations:^{}
                     completion:^(BOOL finished) {
                         if (finished) {_centerButton.enabled = YES;}
                     }];
}

- (void)removeBlurView
{
    _centerButton.enabled = NO;
    
    self.view.alpha = 1;
    [UIView animateWithDuration:0.25f
                     animations:^{}
                     completion:^(BOOL finished) {
                         if(finished) {
                             [_dimView removeFromSuperview];
                             _dimView = nil;
                             
                             [self.blurView removeFromSuperview];
                             self.blurView = nil;
                             _centerButton.enabled = YES;
                         }
                     }];
}


#pragma mark - 处理点击事件

- (void)onTapOptionButton:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.view.tag) {
        case 0: {
            TweetEditingVC *tweetEditingVC = [TweetEditingVC new];
            UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
            [self.selectedViewController presentViewController:tweetEditingNav animated:YES completion:nil];
            break;
        }
        case 1: {
//            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] init];
//            elcPicker.maximumImagesCount = 9;
//            elcPicker.imagePickerDelegate = self;
//            [self presentViewController:elcPicker animated:YES completion:nil];
            
            break;
        }
        case 2: {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Device has no camera"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                
                [alertView show];
            } else {
                UIImagePickerController *imagePickerController = [UIImagePickerController new];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.allowsEditing = NO;
                imagePickerController.showsCameraControls = YES;
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
            break;
        }
        case 3: {
            /*
            ShakingViewController *shakingVC = [ShakingViewController new];
            UINavigationController *shakingNav = [[UINavigationController alloc] initWithRootViewController:shakingVC];
            [self.selectedViewController presentViewController:shakingNav animated:NO completion:nil];
             */
            
            VoiceTweetEditingVC *voiceTweetVC = [VoiceTweetEditingVC new];
            UINavigationController *voiceTweetNav = [[UINavigationController alloc] initWithRootViewController:voiceTweetVC];
            [self.selectedViewController presentViewController:voiceTweetNav animated:NO completion:nil];
            
            break;
        }
        case 4: {
            ScanViewController *scanVC = [ScanViewController new];
            UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
            [self.selectedViewController presentViewController:scanNav animated:NO completion:nil];
            break;
        }
        case 5: {
            PersonSearchViewController *personSearchVC = [PersonSearchViewController new];
            UINavigationController *personSearchNav = [[UINavigationController alloc] initWithRootViewController:personSearchVC];
            [self.selectedViewController presentViewController:personSearchNav animated:YES completion:nil];
            break;
        }
        default: break;
    }
    
    [self buttonPressed];
}




#pragma mark -- UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
    //UIImageWriteToSavedPhotosAlbum(edit, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [picker dismissViewControllerAnimated:NO completion:^{
        TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithImage:info[UIImagePickerControllerOriginalImage]];
        UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
        [self.selectedViewController presentViewController:tweetEditingNav animated:NO completion:nil];
    }];
}


#pragma mark -

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                     target:self
                                                                                                     action:@selector(pushSearchViewController)];
    
    
    return navigationController;
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (self.selectedIndex == 1 && self.selectedIndex == [tabBar.items indexOfObject:item]) {
        SwipableViewController *swipeableVC = (SwipableViewController *)((UINavigationController *)self.selectedViewController).viewControllers[0];
        UIViewController *vc = swipeableVC.viewPager.childViewControllers[swipeableVC.titleBar.currentIndex];
        if ([vc isKindOfClass:[TweetTableViewController class]]) {
            TweetTableViewController *objsViewController = (TweetTableViewController *)vc;
            [objsViewController.tableView.mj_header beginRefreshing];
        }else if([vc isKindOfClass:[OSCTweetRecommendCollectionController class]]){
            OSCTweetRecommendCollectionController *recommendVC = (OSCTweetRecommendCollectionController *)vc;
            [recommendVC.collectionView.mj_header beginRefreshing];
        }
    }
    
    if (self.selectedIndex == 0 && self.selectedIndex == [tabBar.items indexOfObject:item]) {
        UIViewController *firstVC = ((UINavigationController *)self.selectedViewController).viewControllers[0];
        if ([firstVC isKindOfClass:[OSCSyntheticalController class]]) {
            OSCSyntheticalController *currentVC = (OSCSyntheticalController *)firstVC;
            [currentVC beginRefresh];
        }
    }
}

#pragma mark - 处理左右navigationItem点击事件

- (void)pushSearchViewController
{
//    [(UINavigationController *)self.selectedViewController pushViewController:[SearchViewController new] animated:YES];
    UINavigationController *nav = (UINavigationController *)self.selectedViewController;
    OSCSearchViewController *searchVC = [[OSCSearchViewController alloc] init];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [nav presentViewController:searchNav animated:YES completion:^{
        
    }];
}



@end
