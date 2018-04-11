//
//  ViewController.m
//  downloadImageDemo
//
//  Created by 朱标 on 2018/4/11.
//  Copyright © 2018年 朱标. All rights reserved.
//

#import "ViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXSDKInstance.h>

@interface ViewController ()
@property (nonatomic, strong) WXSDKInstance *instance;
@property (nonatomic, assign) CGFloat weexHeight;
@property (nonatomic, strong) UIView *weexView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _weexHeight = self.view.frame.size.height - 64;
    [self render];

}

- (void)render
{
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    CGFloat width = self.view.frame.size.width;
    _instance.frame = CGRectMake(self.view.frame.size.width-width, 64, width, _weexHeight);
    
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, weakSelf.weexView);
    };
    _instance.onFailed = ^(NSError *error) {
        NSLog(@"failed %@",error);
    };
    
    _instance.renderFinish = ^(UIView *view) {
        NSLog(@"render finish");
    };
    
    _instance.updateFinish = ^(UIView *view) {
        NSLog(@"update Finish");
    };
    NSString *url = [NSString stringWithFormat:@"file://%@/loadImage.js",[NSBundle mainBundle].bundlePath];
    NSURL *URL = [self testURL: [[NSURL URLWithString:url] absoluteString]];
    NSString *randomURL = [NSString stringWithFormat:@"%@%@random=%d",URL.absoluteString,URL.query?@"&":@"?",arc4random()];
    [_instance renderWithURL:[NSURL URLWithString:randomURL] options:@{@"bundleUrl":URL.absoluteString} data:nil];
}
#pragma mark - load local device bundle
- (NSURL*)testURL:(NSString*)url
{
    NSRange range = [url rangeOfString:@"_wx_tpl"];
    if (range.location != NSNotFound) {
        NSString *tmp = [url substringFromIndex:range.location];
        NSUInteger start = [tmp rangeOfString:@"="].location;
        NSUInteger end = [tmp rangeOfString:@"&"].location;
        ++start;
        if (end == NSNotFound) {
            end = [tmp length] - start;
        }
        else {
            end = end - start;
        }
        NSRange subRange;
        subRange.location = start;
        subRange.length = end;
        url = [tmp substringWithRange:subRange];
    }
    return [NSURL URLWithString:url];
}



@end
