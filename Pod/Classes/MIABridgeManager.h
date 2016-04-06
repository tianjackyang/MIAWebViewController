//
//  MIABridgeManager.h
//  e-friends
//
//  Created by 杨鹏 on 16/4/6.
//  Copyright © 2016年 上海名扬科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"

@interface MIAWEBBridgeManager : NSObject
+ (MIAWEBBridgeManager*)sharewebBridgeManager;

/**
 *  绑定js和oc
 *
 *  @param webview 要绑定的浏览器对象
 */
- (void)bindWKWebView:(UIWebView*)webview;

/**
 *  注册oc函数到js,js会调用该注册函数
 *
 *  @param handlename 注册的函数名
 *  @param handler    data->js返回的数据，void(^)(id responseData)->js传过来的回调函数
 */
- (void)registerOBJCHandlerByString:(NSString*)handlename handler:(void(^)(id data, void(^)(id responseData)))handler;

/**
 *  注册oc函数到js,js会调用该注册函数
 *
 *  @param handlename 注册多个函数名
 *  @param handler    data->js返回的数据，void(^)(id responseData)->js传过来的回调函数
 */
- (void)registerOBJCHandlerByArray:(NSArray *)handlename handler:(void(^)(id data, void(^)(id responseData)))handler;

/**
 *  oc调用js函数
 *
 *  @param handlename js中的函数名
 */
- (void)callJSHandler:(NSString *)handlename;

/**
 *  oc调用js函数
 *
 *  @param handlename js中的函数名
 *  @param data       oc传给js函数中的参数
 */
- (void)callJSHandler:(NSString *)handlename data:(id)data;

/**
 *  oc调用js函数
 *
 *  @param handlename       js中的函数名
 *  @param data             oc传给js函数中的参数
 *  @param responseCallback void(^)(id responseData)->oc传给js的回调函数
 */
- (void)callJSHandler:(NSString *)handlename data:(id)data responseCallback:(void(^)(id responseData))responseCallback;
@end

@interface MIAWKWEBBridgeManager : NSObject
+ (MIAWKWEBBridgeManager*)sharewkwebBridgeManager;

/**
 *  绑定js和oc
 *
 *  @param wkwebview 要绑定的浏览器对象
 */
- (void)bindWKWebView:(WKWebView*)wkwebview;

/**
 *  注册oc函数到js,js会调用该注册函数
 *
 *  @param handlename 注册的函数名
 *  @param handler    data->js返回的数据，void(^)(id responseData)->js传过来的回调函数
 */
- (void)registerOBJCHandlerByString:(NSString*)handlename handler:(void(^)(id data, void(^)(id responseData)))handler;

/**
 *  注册oc函数到js,js会调用该注册函数
 *
 *  @param handlename 注册多个函数名
 *  @param handler    data->js返回的数据，void(^)(id responseData)->js传过来的回调函数
 */
- (void)registerOBJCHandlerByArray:(NSArray *)handlename handler:(void(^)(id data, void(^)(id responseData)))handler;

/**
 *  oc调用js函数
 *
 *  @param handlename js中的函数名
 */
- (void)callJSHandler:(NSString *)handlename;

/**
 *  oc调用js函数
 *
 *  @param handlename js中的函数名
 *  @param data       oc传给js函数中的参数
 */
- (void)callJSHandler:(NSString *)handlename data:(id)data;

/**
 *  oc调用js函数
 *
 *  @param handlename       js中的函数名
 *  @param data             oc传给js函数中的参数
 *  @param responseCallback void(^)(id responseData)->oc传给js的回调函数
 */
- (void)callJSHandler:(NSString *)handlename data:(id)data responseCallback:(void(^)(id responseData))responseCallback;
@end