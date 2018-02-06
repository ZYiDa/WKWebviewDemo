//
//  WKWebviewController.m
//  KaizeOCR
//
//  Created by YYKit on 2017/6/16.
//  Copyright © 2017年 zl. All rights reserved.
//  首页的WKWebview，用于显示公司主页

#import "WKWebviewController.h"
#import <WebKit/WebKit.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define Top_Offset HEIGHT==812?88:64

@interface WKWebviewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *wkWebview;
@property (nonatomic,strong) UIProgressView *progress;
@property (nonatomic,strong) UIBarButtonItem *leftBarButton;
@property (nonatomic,strong) UIBarButtonItem *leftBarButtonSecond;
@property (nonatomic,strong)  UIBarButtonItem *negativeSpacer;
@property (nonatomic,strong)  UIBarButtonItem *negativeSpacer2;

@end

@implementation WKWebviewController

#pragma mark --- wk
- (WKWebView *)wkWebview
{
    if (_wkWebview == nil)
    {

        _wkWebview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT==812?(HEIGHT - 34):HEIGHT)];
        _wkWebview.UIDelegate = self;
        _wkWebview.navigationDelegate = self;
        _wkWebview.backgroundColor = [UIColor clearColor];
        _wkWebview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wkWebview.multipleTouchEnabled = YES;
        _wkWebview.autoresizesSubviews = YES;
        _wkWebview.scrollView.alwaysBounceVertical = YES;
        _wkWebview.allowsBackForwardNavigationGestures = YES;/**这一步是，开启侧滑返回上一历史界面**/
        [self.view addSubview:_wkWebview];
    }
    return _wkWebview;
}

#pragma mark 加载进度条
- (UIProgressView *)progress
{
    if (_progress == nil)
    {
        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, Top_Offset, WIDTH, 0)];
        _progress.tintColor = [UIColor redColor];
        _progress.backgroundColor = [UIColor redColor];
        [self.view addSubview:_progress];
    }
    return _progress;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self LoadRequest];
    [self addObserver];
    [self setBarButtonItem];

}

#pragma mark 加载网页
- (void)LoadRequest
{
    //TODO:加载
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}


#pragma mark 添加KVO观察者
- (void)addObserver
{
    //TODO:kvo监听，获得页面title和加载进度值，以及是否可以返回
    [self.wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebview addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark 设置BarButtonItem
- (void)setBarButtonItem
{
    //设置距离左边屏幕的宽度距离
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setBackgroundImage:[UIImage imageNamed:@"back_item"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(selectedToBack) forControlEvents:UIControlEventTouchUpInside];
    [back setFrame:CGRectMake(0, 0, 28, 28)];

    self.leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:back];

    //设置关闭按钮，以及关闭按钮和返回按钮之间的距离
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setBackgroundImage:[UIImage imageNamed:@"close_item"] forState:UIControlStateNormal];
    [close setFrame:CGRectMake(0, 0, 25, 25)];
    [close addTarget:self action:@selector(selectedToClose) forControlEvents:UIControlEventTouchUpInside];
    self.leftBarButtonSecond = [[UIBarButtonItem alloc]initWithCustomView:close];
    self.navigationItem.leftBarButtonItems = @[self.leftBarButton];

    if (@available(iOS 11,*)) {
        NSLog(@"11");
    }else{
        NSLog(@"----10011");
    }

    //设置刷新按妞
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reload_item"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(selectedToReloadData)];
    self.navigationItem.rightBarButtonItems = @[reloadItem];

}
#pragma mark 关闭并上一界面
- (void)selectedToClose
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 返回上一个网页还是上一个Controller
- (void)selectedToBack
{
    if (self.wkWebview.canGoBack == 1){
        [self.wkWebview goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark reload
- (void)selectedToReloadData
{
    [self.wkWebview reload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        if (object == self.wkWebview)
        {
            [self.progress setAlpha:1.0f];
            [self.progress setProgress:self.wkWebview.estimatedProgress animated:YES];
            if(self.wkWebview.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:1.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.progress setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [self.progress setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //网页title
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.wkWebview){
            self.title = self.wkWebview.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //是否可以返回
    else if ([keyPath isEqualToString:@"canGoBack"])
    {
        if (object == self.wkWebview){
            if (self.wkWebview.canGoBack == 1){
                self.navigationItem.leftBarButtonItems = @[self.leftBarButton,self.leftBarButtonSecond];
            }else{
                self.navigationItem.leftBarButtonItems = @[self.leftBarButton];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark 在这里处理短暂性的加载错误
/*
 *-1009 没有网络连接
 *-1003
 *-999
 *101
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"ErrorCode:%ld",error.code);
    if (error.code == -1099)
    {
    }
}


#pragma mark 添加返回键和关闭按钮

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
#pragma mark 移除观察者
- (void)dealloc
{
    [self.wkWebview removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebview removeObserver:self forKeyPath:@"canGoBack"];
    [self.wkWebview removeObserver:self forKeyPath:@"title"];
}
@end
