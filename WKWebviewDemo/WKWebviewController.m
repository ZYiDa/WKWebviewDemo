//
//  WKWebviewController.m
//  KaizeOCR
//
//  Created by YYKit on 2017/6/16.
//  Copyright © 2017年 kzkj. All rights reserved.
//  首页的WKWebview，用于显示公司主页

#import "WKWebviewController.h"
#import <WebKit/WebKit.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface WKWebviewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *wkWebview;
@property (nonatomic,strong) UIProgressView *progress;
@end

@implementation WKWebviewController

#pragma mark --- wk
- (WKWebView *)wkWebview
{
    if (_wkWebview == nil)
    {

        _wkWebview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        _wkWebview.UIDelegate = self;
        _wkWebview.navigationDelegate = self;
        _wkWebview.backgroundColor = [UIColor clearColor];
        _wkWebview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wkWebview.multipleTouchEnabled = YES;
        _wkWebview.autoresizesSubviews = YES;
        _wkWebview.scrollView.alwaysBounceVertical = YES;
        _wkWebview.allowsBackForwardNavigationGestures = YES;/**这一步是，开启侧滑返回上一历史界面**/
        NSLog(@"%@",_wkWebview.goBack);
        [self.view addSubview:_wkWebview];
    }
    return _wkWebview;
}

#pragma mark 加载进度条
- (UIProgressView *)progress
{
    if (_progress == nil)
    {
        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, 4)];
        _progress.tintColor = [UIColor redColor];
        _progress.backgroundColor = [UIColor grayColor];
        [self.view addSubview:_progress];
    }
    return _progress;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //TODO:加载
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];

    //TODO:kvo监听，获得页面title和加载进度值
    [self.wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
//    [self.wkWebview addObserver:self forKeyPath:@"backForwardList" options:NSKeyValueObservingOptionNew context:NULL];


}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
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
        if (object == self.wkWebview)
        {
            self.navigationItem.title = self.wkWebview.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
#pragma mark 移除观察者
- (void)dealloc
{
    [self.wkWebview removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebview removeObserver:self forKeyPath:@"title"];
}
@end
