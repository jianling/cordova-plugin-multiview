/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVUserAgentUtil.h>
#import "Multiview.h"

@interface Multiview() {
    UIView* statusBarView;
    UIView* background;
}
@end

@implementation Multiview

- (void)pushView:(CDVInvokedUrlCommand*)command
{
    NSString* moduleName = [command.arguments objectAtIndex:0];
    NSString* moduleTitle = [command.arguments objectAtIndex:1];
    NSString* moduleConfigFile = [command.arguments objectAtIndex:2];

    MainViewController *viewController = [[ViewController alloc] init];

    viewController.startPage = moduleName;
    viewController.configFile = moduleConfigFile;
    viewController.title = moduleTitle;

    [[UINavigationBar appearance] setTranslucent:NO];
    if ([moduleName hasPrefix:@"http:"] || [moduleName hasPrefix:@"https:"]) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:25.0 / 255.0 green:35.0 / 255.0 blue:60.0 / 255.0 alpha:1]];

        UIColor *titleColor = [UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:1];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSForegroundColorAttributeName: titleColor
                                                               }];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
        [viewController.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    } else {
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 64, viewController.view.bounds.size.width, viewController.view.bounds.size.height)];
        background.backgroundColor = [UIColor colorWithRed:218.0 / 255.0 green:222.0 / 255.0 blue:232.0 / 255.0 alpha:1];
        [viewController.view addSubview:background];

        statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewController.view.bounds.size.width, 64)];
        statusBarView.backgroundColor = [UIColor colorWithRed:25.0 / 255.0 green:35.0 / 255.0 blue:60.0 / 255.0 alpha:1];
        [viewController.view addSubview:statusBarView];
        [viewController setNeedsStatusBarAppearanceUpdate];
    }


    if (self.viewController.navigationController == NULL) {
        UINavigationController *nav = [[UINavigationController alloc] init];

        self.webView.window.rootViewController = nav;
        [nav pushViewController:self.viewController animated:false];
        [self.viewController.navigationController setNavigationBarHidden:YES animated:NO];
    }

    [self.viewController.navigationController pushViewController:viewController animated:true];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideNavigationBar:) name:@"hideNavigationBar" object:nil];
}

- (void)popView:(CDVInvokedUrlCommand*)command
{
    [self popView];
}

- (void)popView
{
    [self.viewController.navigationController popViewControllerAnimated:true];

    if (self.viewController.navigationController.childViewControllers.count == 1) {
        [self.viewController.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)hideNavigationBar:(CDVInvokedUrlCommand*)command
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNavigationBar" object:nil];
}

- (void)_hideNavigationBar:(NSNotification*)notification
{
    [statusBarView removeFromSuperview];
    [background removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideNavigationBar" object:nil];
}

@end

@implementation ViewController

- (id)init
{
    self = [super init];

    UIWebView* webView = (UIWebView*) self.webView;

#ifdef __CORDOVA_4_0_0
    webView.delegate = [[CDVUIWebViewDelegate alloc] initWithDelegate:self];
#else
    webView.delegate = [[CDVWebViewDelegate alloc] initWithDelegate:self];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinishLoad:) name:CDVPageDidLoadNotification object:nil];

    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (self.inViewControllerStack) {
        [[UINavigationBar appearance] setTranslucent:NO];
    } else {
        CGRect viewBounds = self.view.bounds;

        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"process.gif" ofType:nil];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];

        SCGIFImageView* gifImageView = [[SCGIFImageView alloc] initWithFrame:CGRectMake((viewBounds.size.width - 60) / 2, (viewBounds.size.height - 60) / 2, 60, 60)];
        [gifImageView setData:imageData];
        [self.view addSubview:gifImageView];

        self.loadingImageView = gifImageView;

        self.inViewControllerStack = true;
    }

    if ([self.startPage hasPrefix:@"http:"] || [self.startPage hasPrefix:@"https:"]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

}

- (void)webViewDidFinishLoad:(NSNotification*)notification
{
    NSLog(@"webViewDidFinishLoad");

    [self.loadingImageView removeFromSuperview];

    if ([self.title isEqualToString:@""]) {
        UIWebView* webView = (UIWebView*) self.webView;
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDVPageDidLoadNotification object:nil];
}

@end

