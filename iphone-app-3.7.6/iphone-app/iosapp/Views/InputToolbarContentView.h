//
//  InputToolbarContentView.h
//  zbapp
//
//  Created by AeternChan on 7/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowingTextView.h"

@interface InputToolbarContentView : UIView

@property (nonatomic, weak) IBOutlet GrowingTextView *editingView;
@property (nonatomic, weak) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *emjioButton;

@end
