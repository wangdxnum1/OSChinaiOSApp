//
//  TweetEditingVC.m
//  iosapp
//
//  Created by ChanAetern on 12/18/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetEditingVC.h"
#import "EmojiPageVC.h"
#import "OSCAPI.h"
#import "TeamAPI.h"
#import "Config.h"
#import "Utils.h"
#import "PlaceholderTextView.h"
#import "NewLoginViewController.h"
#import "ImageViewerController.h"
#import "AppDelegate.h"
#import "TeamMemberListViewController.h"
#import "Config.h"
#import "OSCPhotoGroupView.h"
#import "ImageCollectionViewCell.h"
#import "GACompressionPicHandle.h"
#import "JDStatusBarNotification.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <MBProgressHUD.h>
#import <Ono.h>
#import <ReactiveCocoa.h>
#import "TweetFriendsListViewController.h"
#import <Masonry.h>

#import <TZImagePickerController.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define maxStrLength 160

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface TweetEditingVC () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIScrollViewDelegate ,UICollectionViewDelegate ,UICollectionViewDataSource,TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) PlaceholderTextView   *edittingArea;
@property (nonatomic, strong) UIToolbar             *toolBar;
@property (nonatomic, strong) NSLayoutConstraint    *keyboardHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint    *textViewHeightConstraint;
@property (nonatomic, strong) EmojiPageVC           *emojiPageVC;
@property (nonatomic, assign) BOOL                  isEmojiPageOnScreen;

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) ImageCollectionViewCell *moveCell; //用于记录移动的Cell

@property (nonatomic, strong) UIImage               *image;
@property (nonatomic, strong) NSString              *topicName;
@property (nonatomic, assign) int                   teamID;
@property (nonatomic)         BOOL                  isTeamTweet;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray* imagesData;
@property (nonatomic, copy) NSString *imageToken;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic) NSInteger failCount;
@property (nonatomic) BOOL isGotTweetAddImage;      //是否已有➕图片在images数组里
@property (nonatomic) BOOL isAddImage;          //是否是添加图片模式（点击➕图片添加）

@end

static NSString *headerID = @"header";
static NSString *cellID = @"imageCell";

@implementation TweetEditingVC{
    NSMutableArray* _itemImageArr;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _isTeamTweet = NO;
        _images = [NSMutableArray new];
        _imageToken = @"";
        _imageIndex = 0;
        _failCount = 0;
        _isGotTweetAddImage = NO;
        _isAddImage = NO;
        _itemImageArr = [NSMutableArray arrayWithCapacity:9];
        _imagesData = [NSMutableArray arrayWithCapacity:9];
    }
    return self;
}

//多图
//- (instancetype)initWithImages:(NSMutableArray *)images
//{
//    self = [super init];
//    if (self) {
//        _images = images;
//        _imageToken = @"";
//        _imageIndex = 0;
//        _failCount = 0;
//        _isGotTweetAddImage = NO;
//        _isAddImage = NO;
//    }
//    
//    return self;
//}


- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    
    return self;
}

- (instancetype)initWithTopic:(NSString *)topic
{
    self = [self init];
    if (self) {
        _topicName = topic;
    }
    
    return self;
}

- (instancetype)initWithTeamID:(int)teamID
{
    self = [super init];
    if (self) {
        _teamID = teamID;
        _isTeamTweet = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"弹一弹";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonClicked)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pubTweet)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubViews];
    
//    [self setUpLayoutIsRepeat:NO];
    [self setLayout];
    
    if (!_edittingArea.text.length) {
        _edittingArea.text = [Config getTweetText];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_edittingArea.delegate textViewDidChange:_edittingArea];
    
    [_edittingArea becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initSubViews
{
    CGFloat edittingAreaHeight = (359*190)/(CGRectGetWidth(self.view.frame)-16);
    _edittingArea = [PlaceholderTextView new];
    _edittingArea.frame = CGRectMake(8, 0, kScreenSize.width - 16, edittingAreaHeight);
    _edittingArea.placeholder = @"今天你动弹了吗？";
    _edittingArea.delegate = self;
    if (_topicName.length) {
        _edittingArea.text = [NSString stringWithFormat:@"#%@#", _topicName];
    }
    _edittingArea.returnKeyType = UIReturnKeySend;
    _edittingArea.enablesReturnKeyAutomatically = YES;
    _edittingArea.scrollEnabled = NO;
    _edittingArea.font = [UIFont systemFontOfSize:16];
	_edittingArea.autocorrectionType = UITextAutocorrectionTypeDefault; //why do u guys want to set NO on this?! 
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        _edittingArea.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    
    _edittingArea.backgroundColor = [UIColor whiteColor];
    _edittingArea.textColor = [UIColor titleColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    float width = CGRectGetWidth([[UIScreen mainScreen]bounds])/3 - 12;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 9;
    layout.minimumInteritemSpacing = 9;
    layout.sectionInset = UIEdgeInsetsMake(13, 9, 50, 9);
    layout.headerReferenceSize = CGSizeMake(kScreenSize.width, edittingAreaHeight);
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID];
    [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    [self.view addSubview:_collectionView];
    _collectionView.alwaysBounceVertical = YES;
    
    //移动手势
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveClick:)];
    longPressGR.minimumPressDuration = 0.5;
    [_collectionView addGestureRecognizer:longPressGR];
    
    _emojiPageVC = [[EmojiPageVC alloc] initWithTextView:_edittingArea];
    _emojiPageVC.view.hidden = YES;
    _emojiPageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_emojiPageVC.view];
    
    
    /****** toolBar ******/
    
    _toolBar = [UIToolbar new];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 25.0f;
    NSMutableArray *barButtonItems = [[NSMutableArray alloc] initWithObjects:fixedSpace, nil];
    NSArray *iconName = @[@"toolbar-image", @"toolbar-mention", @"toolbar-reference", @"toolbar-emoji"];
    NSArray *action   = @[@"addImage", @"mentionSomenone", @"referSoftware", @"switchInputView"];
    for (int i = 0; i < 4; i++) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:iconName[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:NSSelectorFromString(action[i])];
        //button.tintColor = [UIColor grayColor];
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
            _toolBar.barTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            button.tintColor = [UIColor clearColor];
        } else {
            _toolBar.barTintColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
            button.tintColor = [UIColor clearColor];
        }
        [barButtonItems addObject:button];
        if (i < 3) {[barButtonItems addObject:flexibleSpace];}
    }
    [barButtonItems addObject:fixedSpace];
    [_toolBar setItems:barButtonItems];
    
    // 底部添加border
    
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor borderColor];
    bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [_toolBar addSubview:bottomBorder];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(bottomBorder);
    
    [_toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bottomBorder]|" options:0 metrics:nil views:views]];
    [_toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBorder(0.5)]|" options:0 metrics:nil views:views]];
    
    [self.view addSubview:_toolBar];
    
    _toolBar.backgroundColor = [UIColor themeColor];
}


/**布局*/
-(void)setLayout{
    
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
    }];
    _keyboardHeightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                toItem:_toolBar  attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:_keyboardHeightConstraint];
    
    /*** emojiPage ***/
    NSDictionary *view = @{@"emojiPage": _emojiPageVC.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiPage(216)]|" options:0 metrics:nil views:view]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[emojiPage]|" options:0 metrics:nil views:view]];
}


//添加大图item
-(void)addItemWithImageView:(UIImageView *)imageView{
    UIImage *image = imageView.image;
    NSData* imageData = UIImagePNGRepresentation(image);
    NSString* imageStr = [[NSString alloc]initWithData:imageData encoding:NSUTF8StringEncoding];
    NSURL* imageUrl = [NSURL URLWithString:imageStr];
    
    OSCPhotoGroupItem* imageItem = [OSCPhotoGroupItem new];
    imageItem.largeImageURL = imageUrl;
    imageItem.largeImageSize = [UIScreen mainScreen].bounds.size;
    imageItem.thumbView = imageView;
    [_itemImageArr addObject:imageItem];
}
//删除
-(void)deleteImageCellWithIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.images removeObjectAtIndex:index];
    [_itemImageArr removeObjectAtIndex:index];
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    //当删除第九张时
    if(_images.count == 8 && !_isGotTweetAddImage){
        _isGotTweetAddImage = YES;
        [_images insertObject:[UIImage imageNamed:@"ic_tweet_add"] atIndex:_images.count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_images.count-1 inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    if (_isGotTweetAddImage && _images.count == 1) {
        [_images removeAllObjects];
        [_collectionView reloadData];
    }
    for (UIView *subView in _contentView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
}
#pragma mark --- 预览大图
-(void)showLargeImageWithIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *fromView = (ImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    NSInteger imageIndex = indexPath.row;
    if (imageIndex < _images.count - 1) {
        [_edittingArea resignFirstResponder];
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:_itemImageArr.copy];
        
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        [photoGroup presentFromImageView:fromView.imageView toContainer:keyWindow animated:YES completion:nil];
        photoGroup.isShowDownloadButton = NO;
    }else if (imageIndex == _images.count - 1) {
        if (_isGotTweetAddImage) {  //在原来基础上添加图片
            _isAddImage = YES;
            TZImagePickerController* albumPrickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:(9 - (_images.count - 1)) delegate:self];
            albumPrickerController.allowPickingOriginalPhoto = NO;
            albumPrickerController.allowPickingVideo = NO;
            albumPrickerController.navigationBar.barTintColor = [UIColor navigationbarColor];
            [self presentViewController:albumPrickerController animated:YES completion:nil];
        }else {
            [self.navigationController presentViewController:[[ImageViewerController alloc] initWithImage:[_images objectAtIndex:imageIndex]] animated:YES completion:nil];
        }
    }
}

- (void)showMutilImagePreview:(UITapGestureRecognizer*)tap {
    NSInteger imageIndex = tap.view.tag;
    if (imageIndex < _images.count - 1) {
        [_edittingArea resignFirstResponder];
        UIImageView* fromView = (UIImageView* )tap.view;
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:_itemImageArr.copy];
        
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        [photoGroup presentFromImageView:fromView toContainer:keyWindow animated:YES completion:nil];
        photoGroup.isShowDownloadButton = NO;
        
    }else if (imageIndex == _images.count - 1) {
        if (_isGotTweetAddImage) {  //在原来基础上添加图片
            _isAddImage = YES;
            TZImagePickerController* albumPrickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:(9 - (_images.count - 1)) delegate:self];
            albumPrickerController.allowPickingOriginalPhoto = NO;
            albumPrickerController.allowPickingVideo = NO;
            albumPrickerController.navigationBar.barTintColor = [UIColor navigationbarColor];
            [self presentViewController:albumPrickerController animated:YES completion:nil];

        }else {
            [self.navigationController presentViewController:[[ImageViewerController alloc] initWithImage:[_images objectAtIndex:imageIndex]] animated:YES completion:nil];
        }
    }
}

- (void)cancelButtonClicked
{
    if (_edittingArea.text.length > 0) {
        NSString *alertString = _teamID? @"是否取消编辑动弹" : @"是否保存已编辑的信息";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertString message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alertView show];
    } else {
        [Config saveTweetText:@"" forUser:[Config getOwnID]];
        [_edittingArea resignFirstResponder];
        
        if (_teamID) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_teamID) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
    } else {
        [Config saveTweetText:buttonIndex == alertView.cancelButtonIndex? @"" : _edittingArea.text
                      forUser:[Config getOwnID]];
    }
    [_edittingArea resignFirstResponder];
    
    if (_teamID) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - ToolBar 高度相关

- (void)keyboardWillShow:(NSNotification *)notification {
    _emojiPageVC.view.hidden = YES;
    _isEmojiPageOnScreen = NO;
    
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeightConstraint.constant = keyboardBounds.size.height;
    
    [self updateBarHeight];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeightConstraint.constant = 0;
    
    [self updateBarHeight];
}
#pragma mark 表情面板与键盘切换

- (void)switchInputView {
    // 还要考虑一下用外接键盘输入时，置空inputView后，字体小的情况
    if (_isEmojiPageOnScreen) {
        [_edittingArea becomeFirstResponder];
        
        [_toolBar.items[7] setImage:[[UIImage imageNamed:@"toolbar-emoji"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _edittingArea.font = [UIFont systemFontOfSize:16];
        _isEmojiPageOnScreen = NO;
        _emojiPageVC.view.hidden = YES;
    } else {
        [_edittingArea resignFirstResponder];
        
        [_toolBar.items[7] setImage:[[UIImage imageNamed:@"toolbar-text"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _keyboardHeightConstraint.constant = 216;
        [self updateBarHeight];
        _isEmojiPageOnScreen = YES;
        _emojiPageVC.view.hidden = NO;
    }
}


- (void)updateBarHeight {
    [self.view setNeedsUpdateConstraints];
    [UIView animateKeyframesWithDuration:0.25       //animationDuration
                                   delay:0
                                 options:7 << 16    //animationOptions
                              animations:^{
                                  [self.view layoutIfNeeded];
                              } completion:nil];
}



#pragma mark - ToolBar 操作

#pragma mark 图片相关

- (void)addImage {
    [self.edittingArea resignFirstResponder]; //键盘遮盖了actionsheet
    
    [[[UIActionSheet alloc] initWithTitle:@"添加图片"
                                 delegate:self
                        cancelButtonTitle:@"取消"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"相册", @"相机", nil]
     
     showInView:self.view];
}




#pragma mark 插入字符串操作（@人，引用软件或发表话题）

- (void)mentionSomenone
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
        return;
    }
    
    if (_teamID) {
        [self.navigationController pushViewController:[TeamMemberListViewController new]
                                             animated:YES];
    }else {
        TweetFriendsListViewController * vc = [TweetFriendsListViewController new];
        [vc setSelectDone:^(NSString *result) {
            [self insertString:result andSelect:NO];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)referSoftware
{
    [self insertString:@"#请输入软件名#" andSelect:YES];
}

- (void)insertString:(NSString *)string andSelect:(BOOL)shouldSelect
{
    [_edittingArea becomeFirstResponder];
    
    NSUInteger cursorLocation = _edittingArea.selectedRange.location;
    [_edittingArea replaceRange:_edittingArea.selectedTextRange withText:string];
    
    if (shouldSelect) {
        UITextPosition *selectedStartPos = [_edittingArea positionFromPosition:_edittingArea.beginningOfDocument offset:cursorLocation + 1];
        UITextPosition *selectedEndPos   = [_edittingArea positionFromPosition:_edittingArea.beginningOfDocument offset:cursorLocation + string.length - 1];
        
        UITextRange *newRange = [_edittingArea textRangeFromPosition:selectedStartPos toPosition:selectedEndPos];
        
        [_edittingArea setSelectedTextRange:newRange];
    }
}

#pragma mark -- 上传动弹多图
- (void)uploadTweetImages {
    [_edittingArea resignFirstResponder];
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
        return;
    }
    self.navigationItem.rightBarButtonItem.accessibilityElementsHidden = YES;
    NSData* postImageData = [_imagesData objectAtIndex:_imageIndex];
    NSString *urlStr = [NSString stringWithFormat:@"%@resource_image", OSCAPI_V2_PREFIX ];
    NSDictionary *paramDic = @{@"token":_imageToken};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager POST:urlStr
       parameters:paramDic
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (postImageData) {
            [formData appendPartWithFileData:postImageData
                                        name:@"resource"
                                    fileName:@"img.png"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"message:%@",responseObject[@"message"]);
        [JDStatusBarNotification showWithStatus:@"正在上传图片..."];

        if ([responseObject[@"code"]integerValue] == 1) {
            _imageIndex += 1;
            _imageToken = responseObject[@"result"][@"token"];
            if (_imageIndex < _images.count) {
            [self uploadTweetImages];
            }else if (_imageIndex == _images.count) {
                [self pubTweetIsWithImages:YES];
            }
        }else {
            _failCount += 1;
            _imageIndex += 1;
            if (_imageIndex < _images.count) {
                [self uploadTweetImages];
            }else if (_imageIndex == _images.count) {
                [self pubTweetIsWithImages:YES];
            }
            [JDStatusBarNotification showWithStatus:@"上传图片失败" dismissAfter:1.0f];
        }
    
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        _imageIndex = 0;
        _failCount = 0;
        _imageToken = @"";
        [JDStatusBarNotification showWithStatus:@"上传图片失败,请重新发送动弹." dismissAfter:1.0f];
    }];
}

#pragma mark -- 发表多图动弹
- (void)pubTweetIsWithImages:(BOOL)isImgTweet {
//    9752556
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
	
	NSString *txtContent = [_edittingArea.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if([txtContent isEqualToString:@"#请输入软件名#"]) {
		
	} else {
        JDStatusBarView *textStauts;
		if (!isImgTweet) {
           textStauts = [JDStatusBarNotification showWithStatus:@"动弹发送中.."];
		}
		NSString *urlStr = [NSString stringWithFormat:@"%@tweet", OSCAPI_V2_PREFIX];
		NSDictionary *paramDic = @{
								   @"content":[Utils convertRichTextToRawText:_edittingArea],
								   @"images":_imageToken
								   };
		AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
		[manger POST:urlStr
		  parameters:paramDic
			 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
				 NSLog(@"tweetMessage:%@",responseObject[@"message"]);
				 
				 if ([responseObject[@"code"]integerValue] == 1) {
					 //提示上传图片失败信息
					 if (isImgTweet) {       //图片动弹
                         JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"图片上传成功"];
						 if (_failCount > 0) {
                             stauts.textLabel.text = [NSString stringWithFormat:@"%ld张图片上传失败", (long)_failCount];
                             [JDStatusBarNotification dismissAfter:2];
						 }else {
                             stauts.textLabel.text = @"动弹发送成功";
                             [JDStatusBarNotification dismissAfter:2];
						 }
					 }else {     //文字动弹
                         textStauts.textLabel.text = @"动弹发送成功";
                         [JDStatusBarNotification dismissAfter:2];
                         
                         [Config saveTweetText:@"" forUser:[Config getOwnID]];
					 }
				 }else {
                     textStauts.textLabel.text = @"动弹发送失败";
                     [JDStatusBarNotification dismissAfter:2];
				 }
				 dispatch_async(dispatch_get_main_queue(), ^{
					 [self dismissViewControllerAnimated:YES completion:nil];
				 });
			 }
			 failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 [JDStatusBarNotification showWithStatus:@"动弹发送失败" dismissAfter:3.0f];
				 NSLog(@"%@",error);
			 }];
	}
}

#pragma mark 发表动弹

- (void)pubTweet {
    [JDStatusBarNotification showWithStatus:@"正在发送动弹..."];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!_isTeamTweet) {
        if (_images.count > 0) {    //发布图片动弹
            if(_isGotTweetAddImage) {       //移除最后一张提示图片
                [_images removeLastObject];
            }
            [self uploadTweetImages];
        }else {    //发布文字动弹
            [self pubTweetIsWithImages:NO];
        }
		
    }else {     //团队动弹
        [self pubTeamTweet];
    }
	
}


#pragma mark -- 发表团队动弹
- (void)pubTeamTweet {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.accessibilityElementsHidden = YES;
    [JDStatusBarNotification showWithStatus:@"动弹发送中"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = _teamID? TEAM_TWEET_PUB : OSCAPI_TWEET_PUB;
        [manager             POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, API]
                       parameters:@{
                                    @"uid": @([Config getOwnID]),
                                    @"msg": [Utils convertRichTextToRawText:_edittingArea],
                                    @"teamid": @(_teamID)
                                    }
         
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        }
         
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
                              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
                              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                              
                              if (errorCode == 1) {
                                  _edittingArea.text = @"";
                                  
                                  [JDStatusBarNotification showWithStatus:@"动弹发送成功" dismissAfter:2.0f];
                                  
                                  [Config saveTweetText:@"" forUser:[Config getOwnID]];
                              } else {
                                  
                                  [Config saveTweetText:_edittingArea.text forUser:[Config getOwnID]];
                                  [JDStatusBarNotification showWithStatus:@"动弹发送失败" dismissAfter:2.0f];
                              }
                              
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [JDStatusBarNotification showWithStatus:@"动弹发送失败" dismissAfter:2.0f];

                              [Config saveTweetText:_edittingArea.text forUser:[Config getOwnID]];
                          }];
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == 0) {
        
        _isAddImage = NO;
        
        TZImagePickerController* albumPrickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
        albumPrickerController.allowPickingOriginalPhoto = NO;
        albumPrickerController.allowPickingVideo = NO;
        albumPrickerController.navigationBar.barTintColor = [UIColor navigationbarColor];
        [self presentViewController:albumPrickerController animated:YES completion:nil];
        
    } else {
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
    }
}
#pragma mark TZImagePickerController Delegate

- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
                        infos:(NSArray<NSDictionary *> *)infos
{
    NSMutableArray* imagesData = [NSMutableArray arrayWithCapacity:photos.count];
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:photos.count];
    NSMutableArray *imageIndexPath = [[NSMutableArray alloc] init];
    for (UIImage* image in photos) {
        NSData* compressionImageData = nil;
        NSData* sourceImageData = UIImagePNGRepresentation(image);
        if (sourceImageData.length > stand_size) {
            CGFloat sourceImage_W = CGImageGetWidth(image.CGImage);
            CGFloat sourceImage_H = CGImageGetHeight(image.CGImage);
            CGFloat tagerImage_W = 0;
            CGFloat tagerImage_H = 0;
            if (sourceImage_W > CompressionMax_W) {
                tagerImage_W = CompressionMax_W;
                CGFloat scale = sourceImage_W / sourceImage_H;
                tagerImage_H = tagerImage_W / scale;
            }else{
                tagerImage_W = sourceImage_W;
                tagerImage_H = sourceImage_H;
            }
            GACompressionPicHandle* compressPicHandle = [GACompressionPicHandle shareCompressionPicHandle];
            compressionImageData = [compressPicHandle imageByScalingAndCroppingForSize:(CGSizeMake(tagerImage_W, tagerImage_H)) image:image];
        }else{
            compressionImageData = sourceImageData;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_images.count + images.count - 1 inSection:0];
        [imageIndexPath addObject:indexPath];
        [imagesData addObject:compressionImageData];
        [images addObject:image];
    }
    if (!_isAddImage) {
        [_images removeAllObjects];
        [_itemImageArr removeAllObjects];
        [_collectionView reloadData];
    }else {
        [_images removeLastObject];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_images.count inSection:0]]];
    }
    [_imagesData addObjectsFromArray:imagesData];
    [_images addObjectsFromArray:images];
    _isGotTweetAddImage = NO;
    if (_images.count > 0 && _images.count < 9 && !_isGotTweetAddImage) {
        _isGotTweetAddImage = YES;
        [_images insertObject:[UIImage imageNamed:@"ic_tweet_add"] atIndex:_images.count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_images.count-1 inSection:0];
        [imageIndexPath addObject:indexPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        for (UIView *subView in _contentView.subviews) {
//            if ([subView isKindOfClass:[UIImageView class]]) {
//                [subView removeFromSuperview];
//            }
//        }
        //        [self setUpLayoutIsRepeat:YES];
        if (_isAddImage) {
            [_collectionView insertItemsAtIndexPaths:imageIndexPath];
        }
        [picker dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController 回调函数

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_images removeAllObjects];
    [_imagesData removeAllObjects];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_images addObject:image];
    //图片压缩
    NSData* compressionImageData = nil;
    NSData* sourceImageData = UIImagePNGRepresentation(image);
    if (sourceImageData.length > stand_size) {
        CGFloat sourceImage_W = CGImageGetWidth(image.CGImage);
        CGFloat sourceImage_H = CGImageGetHeight(image.CGImage);
        CGFloat tagerImage_W = 0;
        CGFloat tagerImage_H = 0;
        if (sourceImage_W > CompressionMax_W) {
            tagerImage_W = CompressionMax_W;
            CGFloat scale = sourceImage_W / sourceImage_H;
            tagerImage_H = tagerImage_W / scale;
        }else{
            tagerImage_W = sourceImage_W;
            tagerImage_H = sourceImage_H;
        }
        GACompressionPicHandle* compressPicHandle = [GACompressionPicHandle shareCompressionPicHandle];
        compressionImageData = [compressPicHandle imageByScalingAndCroppingForSize:(CGSizeMake(tagerImage_W, tagerImage_H)) image:image];
    }else{
        compressionImageData = sourceImageData;
    }
    [_imagesData addObject:compressionImageData];
    
    _isGotTweetAddImage = YES;
    [_images insertObject:[UIImage imageNamed:@"ic_tweet_add"] atIndex:_images.count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        for (UIView *subView in _contentView.subviews) {
//            if ([subView isKindOfClass:[UIImageView class]]) {
//                [subView removeFromSuperview];
//            }
//        }
//        [self setUpLayoutIsRepeat:YES];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [_collectionView reloadData];
    });
    
    //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
    //UIImageWriteToSavedPhotosAlbum(edit, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    
    return len + numMatch;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen = maxStrLength - comcatstr.length;
    if (caninputlen < 0) {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length > 0) {
            NSString *s = [text substringWithRange:rg];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"最多只能输入160字";
        HUD.removeFromSuperViewOnHide = NO;
        [HUD hideAnimated:YES afterDelay:1];
        _edittingArea.text = [_edittingArea.text substringToIndex:_edittingArea.text.length-1];
        return NO;
    }
    
    if ([text isEqualToString: @"\n"]) {
        [self pubTweet];
        [textView resignFirstResponder];
        return NO;
    }
    
    if (_teamID && [text isEqualToString: @"@"]) {
        [self mentionSomenone];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}

- (void)textViewDidChange:(PlaceholderTextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        [_edittingArea resignFirstResponder];
        
        if (_keyboardHeightConstraint.constant != 0) {
            _emojiPageVC.view.hidden = YES;
            _isEmojiPageOnScreen = NO;
            [_toolBar.items[7] setImage:[[UIImage imageNamed:@"toolbar-emoji"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            
            _keyboardHeightConstraint.constant = 0;
            [self updateBarHeight];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.image = _images[indexPath.row];
    cell.deleteCell = ^(ImageCollectionViewCell *cell){
        NSIndexPath *index = [collectionView indexPathForCell:cell];
        [self deleteImageCellWithIndex:index.row];
    };
    cell.isLast = NO;
    if(indexPath.row == _images.count - 1 && _isGotTweetAddImage){
        cell.isLast = YES;
    }else{
        [self addItemWithImageView:cell.imageView];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
    if (![headerView.subviews containsObject:_edittingArea]) {
        [headerView addSubview:_edittingArea];
    }
    return headerView;
}

//移动待定
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0){
    if(indexPath.row == _images.count - 1 && _isGotTweetAddImage){
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0){
    UIImage *image = _images[sourceIndexPath.row];
    [_images removeObject:image];
    [_images insertObject:image atIndex:destinationIndexPath.row];
    OSCPhotoGroupItem *item = _itemImageArr[sourceIndexPath.row];
    [_itemImageArr removeObject:item];
    [_itemImageArr insertObject:item atIndex:destinationIndexPath.row];
    NSData *data = _imagesData[sourceIndexPath.row];
    [_imagesData removeObject:data];
    [_imagesData insertObject:data atIndex:destinationIndexPath.row];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showLargeImageWithIndexPath:indexPath];
}

#pragma mark -MoveCell
-(void)moveClick:(UILongPressGestureRecognizer *)longPressGR{
    if (longPressGR.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[longPressGR locationInView:_collectionView]];
        if (!(indexPath.row == _images.count - 1 && _isGotTweetAddImage)) {
            _moveCell = (ImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            if (_moveCell) {
                [_collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
                [UIView animateWithDuration:0.3 animations:^{
                    _moveCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
                    _moveCell.alpha = 0.8;
                }];
            }
        }
    }else if (longPressGR.state == UIGestureRecognizerStateChanged){
        CGPoint point = [longPressGR locationInView:_collectionView];
        float width = CGRectGetWidth([[UIScreen mainScreen]bounds])/3 - 12;
        CGPoint postionPoint = CGPointMake(point.x - width * 0.3, point.y - width * 0.3);
        CGRect rectOfCurrent = CGRectMake(postionPoint.x, postionPoint.y, width*0.6, width*0.6);
        UICollectionViewCell *lastCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_images.count - 1 inSection:0]];
        CGRect rectOfLast = lastCell.frame;
//        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[longPressGR locationInView:_collectionView]];
//        if(!(indexPath.row == _images.count - 1 && _isGotTweetAddImage))
        if (!(!CGRectIsNull(CGRectIntersection(rectOfCurrent, rectOfLast)) && _isGotTweetAddImage)) {
            [_collectionView updateInteractiveMovementTargetPosition:[longPressGR locationInView:_collectionView]];
        }else if (!CGRectIsNull(CGRectIntersection(rectOfCurrent, rectOfLast)) && _isGotTweetAddImage){
            if (_moveCell) {
                [_collectionView endInteractiveMovement];
                [UIView animateWithDuration:0.3 animations:^{
                    _moveCell.transform = CGAffineTransformMakeScale(1, 1);
                    _moveCell.alpha = 1;
                }];
                _moveCell = nil;
            }
        }
        _moveCell.alpha = 0.8;
        _moveCell.transform = CGAffineTransformMakeScale( 1.2, 1.2);
    }else{
        if(_moveCell){
            [_collectionView endInteractiveMovement];
            [UIView animateWithDuration:0.3 animations:^{
                _moveCell.transform = CGAffineTransformMakeScale(1, 1);
                _moveCell.alpha = 1;
            }];
            _moveCell = nil;
        }
    }
}

@end
