//
//  RxWebViewNavigationViewController.h
//  MIAWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIAWebViewNavigationViewController : UINavigationController
/**
 *  由于 popViewController 会触发 shouldPopItems，因此用该布尔值记录是否应该正确 popItems
 *  点击返回按钮会触发shouldPopItems，然后调用popViewController
 */
@property BOOL shouldPopItemAfterPopViewController;

@end
