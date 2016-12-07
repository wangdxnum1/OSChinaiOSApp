//
//  OSCFunctionIntroManager.h
//  iosapp
//
//  Created by Graphic-one on 16/11/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OSCIntroView;
@interface OSCFunctionIntroManager : NSObject

+ (OSCIntroView* )showIntroPage;

@end



@interface OSCIntroView : UIView

@property (nonatomic,copy) void (^didClickAddButtonBlock)();

- (void)animation;

@end
