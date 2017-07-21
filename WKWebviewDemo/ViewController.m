//
//  ViewController.m
//  WKWebviewDemo
//
//  Created by YYKit on 2017/7/20.
//  Copyright © 2017年 kzkj. All rights reserved.
//

#import "ViewController.h"
#import "WKWebviewController.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlTextField.delegate = self;

    //TODO:禁用屏幕边缘滑动返回手势
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    //TODO:设置返回按键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = back;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.urlTextField.text = @"http://";
}

#pragma mark 输入完成后，点击键盘上的go/前往
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self webEvents];
    return YES;
}


- (IBAction)gotoWebview:(id)sender
{
    [self webEvents];
}

- (void)webEvents
{
    WKWebviewController *webVC = [WKWebviewController new];
    webVC.urlString = self.urlTextField.text;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
