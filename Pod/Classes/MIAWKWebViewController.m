//
//  MIAWebViewController.m
//  MIAWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import "MIAWKWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "MIAWebViewNavigationViewController.h"

#define boundsWidth self.view.bounds.size.width
#define boundsHeight self.view.bounds.size.height
@interface MIAWKWebViewController ()<UINavigationControllerDelegate,UINavigationBarDelegate, WKNavigationDelegate, WKUIDelegate/*, WKScriptMessageHandler*/>


@property (nonatomic,assign) BOOL isShowUrlTitle;
@property (nonatomic,strong) UILabel *urlTipLabel;
@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic)UIBarButtonItem* customBackBarItem;
@property (nonatomic)UIBarButtonItem* closeButtonItem;

/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@end

@implementation MIAWKWebViewController

-(UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - init
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        self.url = url;
        //_progressViewColor = [UIColor colorWithRed:119.0/255 green:228.0/255 blue:115.0/255 alpha:1];
        //_progressColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //config navigation item
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.isShowUrlTitle = !self.title.length;
    self.isShowUrlTitle ? self.title = @"正在加载..." : self.title;
    
    [self.view addSubview:self.webView];
    //[self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(ModifyWebViewRequestHeader:)]) {
            [self.webView loadRequest:[self.delegate ModifyWebViewRequestHeader:self.url]];
        }
        else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        }
    });
    
    //将进度条添加到导航栏下面
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    //添加进度条和标题 监听
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.progressView removeFromSuperview];
}

#pragma mark - lazy load
- (UIProgressView *)progressView {
    if (!_progressView) {
        CGRect barBounds = self.navigationController.navigationBar.bounds;
        CGRect progressFrame = CGRectMake(0, barBounds.size.height, barBounds.size.width, 3.0f);
        _progressView = [[UIProgressView alloc] initWithFrame:progressFrame];
        _progressView.alpha = 0.0f;
        _progressView.progressTintColor = self.progressColor ? self.progressColor : [UIColor colorWithRed:119.0/255 green:228.0/255 blue:115.0/255 alpha:1];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [_webView addGestureRecognizer:self.swipePanGesture];
        [self.view addSubview:_webView];
    }
    return _webView;
}


- (UILabel *)urlTipLabel {
    if (!_urlTipLabel) {
        CGRect frame = CGRectMake(0, 10, self.view.frame.size.width, 20);
        _urlTipLabel = [[UILabel alloc] initWithFrame:frame];
        _urlTipLabel.backgroundColor = [UIColor clearColor];
        _urlTipLabel.textColor = [UIColor redColor];
        _urlTipLabel.textAlignment = NSTextAlignmentCenter;
        [self.webView addSubview:_urlTipLabel];
        [self.webView insertSubview:_urlTipLabel belowSubview:self.webView.scrollView];
    }
    return _urlTipLabel;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeBackForward: {
            break;
        }
        case WKNavigationTypeReload: {
            break;
        }
        case WKNavigationTypeFormResubmitted: {
            break;
        }
        case WKNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (self.webView.title.length > 10) {
            self.title = [[self.webView.title substringToIndex:9] stringByAppendingString:@"…"];
        }
        else {
            self.title = self.webView.title;
        }
    }
}

#pragma mark - overide
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"title" context:NULL];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:NULL];
}

#pragma mark - public funcs
-(void)reloadWebView{
    [self.webView reload];
}

#pragma mark - logic of push and pop snap shot views
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView* currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
    //    NSLog(@"now array count %d",self.snapShotsArray.count);
}

-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    //    NSLog(@"prev center x%f",prevSnapshotViewCenter.x);
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.webView goBack];
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

#pragma mark - update nav items

-(void)updateNavigationItems{
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[self.closeButtonItem] animated:NO];
        
        //弃用customBackBarItem，使用原生backButtonItem
        //        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil];
    }
}

#pragma mark - events handler
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    //    NSLog(@"pan x %f,pan y %f",translation.x,translation.y);
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

-(void)customBackItemClicked{
    [self.webView goBack];
}

#define DYNAMIC_CAST(x, cls)                        \
({                                                 \
cls *inst_ = (cls *)(x);                        \
[inst_ isKindOfClass:[cls class]]? inst_ : nil; \
})

-(void)closeItemClicked{
    [DYNAMIC_CAST(self.navigationController, MIAWebViewNavigationViewController) setShouldPopItemAfterPopViewController:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setters and getters
-(void)setUrl:(NSURL *)url{
    _url = url;
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}
@end