//
//  MIABridgeManager.m
//  e-friends
//
//  Created by 杨鹏 on 16/4/6.
//  Copyright © 2016年 上海名扬科技股份有限公司. All rights reserved.
//

#import "MIABridgeManager.h"
static MIAWEBBridgeManager * sharewebBridgeInstance = nil;
static MIAWKWEBBridgeManager * sharewkwebBridgeInstance = nil;

@interface MIAWEBBridgeManager ()
@property WebViewJavascriptBridge* webbridge;
@property (nonatomic, strong) NSMutableArray *registerOBJCHandler;

@end

@interface MIAWKWEBBridgeManager ()
@property WKWebViewJavascriptBridge* wkwebbridge;
@property (nonatomic, strong) NSMutableArray *registerOBJCHandler;

@end

@implementation MIAWEBBridgeManager
@synthesize webbridge = _webbridge;

+ (MIAWEBBridgeManager*)sharewebBridgeManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharewebBridgeInstance = [[MIAWEBBridgeManager alloc] init];
        [WebViewJavascriptBridge enableLogging];
    });
    
    return sharewebBridgeInstance;
}

- (void)bindWKWebView:(UIWebView*)webview {
    _webbridge = [WebViewJavascriptBridge bridgeForWebView:webview];
}

- (void)registerOBJCHandlerByString:(NSString*)handlename handler:(void(^)(id data, void(^)(id responseData)))handler {
    [_webbridge registerHandler:handlename handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
        handler(data, responseCallback);
    }];
}

- (void)registerOBJCHandlerByArray:(NSArray *)handlename handler:(void(^)(id data, void(^)(id responseData)))handler {
    for (NSString *str in handlename) {
        [_webbridge registerHandler:str handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"testObjcCallback called: %@", data);
            responseCallback(@"Response from testObjcCallback");
            handler(data, responseCallback);
        }];
    }
}

- (void)callJSHandler:(NSString *)handlename {
    [_webbridge callHandler:handlename];
}

- (void)callJSHandler:(NSString *)handlename data:(id)data {
    [_webbridge callHandler:handlename data:data];
}

- (void)callJSHandler:(NSString *)handlename data:(id)data responseCallback:(void(^)(id responseData))responseCallback {
    [_webbridge callHandler:handlename data:data responseCallback:^(id responseData) {
        NSLog(@"testJavascriptHandler responded: %@", responseData);
        responseCallback(responseData);
    }];
}

@end

@implementation MIAWKWEBBridgeManager

+ (MIAWKWEBBridgeManager*)sharewkwebBridgeManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharewkwebBridgeInstance = [[MIAWKWEBBridgeManager alloc] init];
        [WKWebViewJavascriptBridge enableLogging];
    });
    return sharewkwebBridgeInstance;
}

- (void)bindWKWebView:(WKWebView*)wkwebview {
    _wkwebbridge = [WKWebViewJavascriptBridge bridgeForWebView:wkwebview];
}

- (void)registerOBJCHandlerByString:(NSString*)handlename handler:(void(^)(id data, void(^)(id responseData)))handler {
    [_wkwebbridge registerHandler:handlename handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
        handler(data, responseCallback);
    }];
}

- (void)registerOBJCHandlerByArray:(NSArray *)handlename handler:(void(^)(id data, void(^)(id responseData)))handler {
    for (NSString *str in handlename) {
        [_wkwebbridge registerHandler:str handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"testObjcCallback called: %@", data);
            responseCallback(@"Response from testObjcCallback");
            handler(data, responseCallback);
        }];
    }
}

- (void)callJSHandler:(NSString *)handlename {
    [_wkwebbridge callHandler:handlename];
}

- (void)callJSHandler:(NSString *)handlename data:(id)data {
    [_wkwebbridge callHandler:handlename data:data];
}

- (void)callJSHandler:(NSString *)handlename data:(id)data responseCallback:(void(^)(id responseData))responseCallback {
    [_wkwebbridge callHandler:handlename data:data responseCallback:^(id responseData) {
        NSLog(@"testJavascriptHandler responded: %@", responseData);
        responseCallback(responseData);
    }];
}

@end
