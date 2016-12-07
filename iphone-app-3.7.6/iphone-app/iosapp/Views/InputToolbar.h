//
//  InputToolbar.h
//  zbapp
//
//  Created by AeternChan on 7/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowingTextView.h"

@protocol InputBarDelegate <NSObject>

- (void)sendImage:(UIImage *)image;

@end

@interface InputToolbar : UIToolbar <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) GrowingTextView *editingView;
@property (nonatomic, weak) UIButton* imageButton;
@property (nonatomic, weak) UIButton* emjioButton;

@property (nonatomic, weak) UIViewController <InputBarDelegate> *superVC;

@end
