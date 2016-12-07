//
//  InputToolbar.m
//  zbapp
//
//  Created by AeternChan on 7/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "InputToolbar.h"
#import "InputToolbarContentView.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation InputToolbar {
    InputToolbarContentView *contentView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    contentView = [self loadContentView];
    contentView.frame = self.bounds;
    [self addSubview:contentView];
    
    [self.imageButton addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
}

- (InputToolbarContentView *)loadContentView {
    NSArray *nibViews = [[NSBundle bundleForClass:[InputToolbar class]] loadNibNamed:NSStringFromClass([InputToolbarContentView class])
                                                                               owner:nil
                                                                             options:nil];
    return nibViews.firstObject;
}


#pragma mark - getter method

- (GrowingTextView *)editingView {
    return contentView.editingView;
}
- (UIButton *)imageButton {
    return contentView.imageButton;
}
- (UIButton *)emjioButton{
    return contentView.emjioButton;
}



#pragma mark - ActionSheet

- (void)showActionSheet {
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [self.editingView resignFirstResponder];
    [actionSheet showInView:self.window];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == 0) {
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
            
            [_superVC presentViewController:imagePickerController animated:YES completion:nil];
        }
    } else {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = NO;
        
        [_superVC presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController 回调函数

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_superVC sendImage:image];
    
    //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
    //UIImageWriteToSavedPhotosAlbum(edit, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
