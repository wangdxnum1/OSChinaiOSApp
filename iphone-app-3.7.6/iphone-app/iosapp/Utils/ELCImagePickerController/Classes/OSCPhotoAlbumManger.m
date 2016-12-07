//
//  OSCPhotoAlbumManger.m
//  iosapp
//
//  Created by Graphic-one on 16/7/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPhotoAlbumManger.h"
#import <AssetsLibrary/AssetsLibrary.h>//iOS9.0彻底弃用
#import <Photos/Photos.h>//iOS8.0开始使用

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

/** ALAssetsLibrary Method */
#pragma mark -
#pragma mark --- ALAssetsLibrary Extension
@interface ALAssetsLibrary (AssetsLibrary)

- (void)writeImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(AlbumCompleteHanle)completionHandler;

@end

@implementation ALAssetsLibrary (AssetsLibrary)

- (void)writeImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(AlbumCompleteHanle)completionHandler {
    [self writeImageToSavedPhotosAlbum:image.CGImage
                           orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:^(NSURL *assetURL, NSError *error) {
                           if (error) {
                               if (completionHandler) {
                                   completionHandler(error, YES);
                               }
                           } else {
                               [self addAssetURL:assetURL
                                         toAlbum:album
                               completionHandler:^(NSError *error) {
                                   if (completionHandler) {
                                       completionHandler(error, YES);
                                   }
                               }];
                           }
                       }];
}
- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)album completionHandler:(ALAssetsLibraryAccessFailureBlock)completionHandler {
    void (^assetForURLBlock)(NSURL *, ALAssetsGroup *) = ^(NSURL *URL, ALAssetsGroup *group) {
        [self assetForURL:assetURL
              resultBlock:^(ALAsset *asset) {
                  [group addAsset:asset];
                  completionHandler(nil);
              }
             failureBlock:^(NSError *error) { completionHandler(error); }];
    };
    __block ALAssetsGroup *group;
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *_group, BOOL *stop) {
                            if ([album isEqualToString:[_group valueForProperty:ALAssetsGroupPropertyName]]) {
                                group = _group;
                            }
                            if (!_group) {
                                /// 循环结束
                                if (group) {
                                    assetForURLBlock(assetURL, group);
                                } else {
                                    [self addAssetsGroupAlbumWithName:album
                                                          resultBlock:^(ALAssetsGroup *group) { assetForURLBlock(assetURL, group); }
                                                         failureBlock:completionHandler];
                                }
                            }
                        }
                      failureBlock:completionHandler];
}

@end




/** PHPhotoLibrary Method */
#pragma mark -
#pragma mark --- PHAssetCollection Extension
@interface PHAssetCollection (getCollection)
+ (instancetype) collectionWithAlbumName:(NSString* )albumName;

@end

@implementation PHAssetCollection (getCollection)
/** 返回相册 (没有相册就创建) */
+ (instancetype) collectionWithAlbumName:(NSString *)albumName{
    // 获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            return collection;
        }
    }
    
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}

@end


#pragma mark --- PHPhotoLibrary Extension
@interface PHPhotoLibrary (saveImage)
/**
 *  保存图片方法
 *
 *  @param AlbumName     保存的相册名字 如果相册名字为空 就保存到系统相册内
 *  @param image         源图片
 *  @param completeHanle 完成回调
 */
+ (void) saveImageToAlbum:(nullable NSString* )albumName
              sourceImage:(UIImage* )image
       albumCompleteHanle:(AlbumCompleteHanle)completeHanle;

@end

@implementation PHPhotoLibrary (saveImage)
+ (void) saveImageToAlbum:(nullable NSString* )albumName
              sourceImage:(UIImage* )image
       albumCompleteHanle:(AlbumCompleteHanle)completeHanle
{
//先存储图片到"相机胶卷"
    __block NSString *assetId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {  return ; }
        if (albumName == nil) { //如果是保存到系统相册 就结束
            if (completeHanle) {
                completeHanle(error , YES);
                return ;
            }
        }else{  //再存储图片到"自定义相册"
            PHAssetCollection* collection = [PHAssetCollection collectionWithAlbumName:albumName];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completeHanle) {
                    completeHanle(error , YES);
                }
            }];
        }
    }];
}

@end












@interface OSCPhotoAlbumManger ()
@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation OSCPhotoAlbumManger

static OSCPhotoAlbumManger* _sharePhotoAlbumManger;
+ (instancetype)sharePhotoAlbumManger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharePhotoAlbumManger = [[OSCPhotoAlbumManger alloc] init];
    });
    return _sharePhotoAlbumManger;
}

- (void)saveImage:(UIImage *)image
        albumName:(NSString *)albumName
   completeHandle:(AlbumCompleteHanle)completeHandle
{
    if (![self getUserStatus]) {
        if (completeHandle) { completeHandle (nil , NO);}
        return;
    };

    if (kSystemVersion < 9.0) { //use AssetsLibrary
        [self.assetsLibrary writeImage:image toAlbum:albumName completionHandler:^(NSError *error, BOOL isHasAuthorized) {
            if (completeHandle) {
                completeHandle (error,YES);
            }
            self.assetsLibrary = nil;///这里每次都置空是因为期间如果操作相册了，下次保存之前希望能取到最新状态。
        }];
    }else{  //use Photos
        [PHPhotoLibrary saveImageToAlbum:albumName sourceImage:image albumCompleteHanle:^(NSError *error, BOOL isHasAuthorized) {
            if (completeHandle) {
                completeHandle(error , isHasAuthorized);
            }
        }];
    }
}

/** 判断用户是否有给予应用相册权限 */
- (BOOL) getUserStatus {
    if (kSystemVersion < 9.0) { //use AssetsLibrary
        ALAuthorizationStatus AlStatus = [ALAssetsLibrary authorizationStatus];
        switch (AlStatus) {
            case ALAuthorizationStatusNotDetermined://未作出选择
                return YES;
                break;
                
            case ALAuthorizationStatusRestricted://未被授权
                return NO;
                break;
                
            case ALAuthorizationStatusDenied://明确否认
                return NO;
                break;
                
            case ALAuthorizationStatusAuthorized://已经授权
                return YES;
                break;
            default:
                break;
        }
    }else{  //use Photos
        PHAuthorizationStatus PhStatus = [PHPhotoLibrary authorizationStatus];
        switch (PhStatus) {
            case PHAuthorizationStatusNotDetermined://未作出选择
                return YES;
                break;
                
            case PHAuthorizationStatusRestricted://未被授权
                return NO;
                break;
                
            case PHAuthorizationStatusDenied://明确否认
                return NO;
                break;
                
            case PHAuthorizationStatusAuthorized://已经授权
                return YES;
                break;
                
            default:
                break;
        }
    }
}

#pragma mark --- lazy load
- (ALAssetsLibrary *)assetsLibrary {
    if(_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}
@end





