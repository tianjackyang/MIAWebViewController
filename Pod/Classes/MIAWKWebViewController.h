//
//  RxWebViewController.h
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MIAWebProtocol.h"

@interface MIAWKWebViewController : UIViewController

@property (nonatomic, strong) id<MIAWebProtocol> delegate;

/**
 *  origin url
 */
@property (nonatomic)NSURL* url;

/**
 *  embed webView
 */
@property (nonatomic)WKWebView* webView;


/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
-(instancetype)initWithUrl:(NSURL*)url;


-(void)reloadWebView;

/**
 *  进度条颜色
 */
@property (nonatomic,strong) UIColor *progressColor;

@property (nonatomic,assign) BOOL isShowOrigin;

@end



