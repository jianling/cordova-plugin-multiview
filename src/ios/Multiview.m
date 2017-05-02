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

@implementation Multiview

- (void)pushView:(CDVInvokedUrlCommand*)command
{
    NSString* moduleName = [command.arguments objectAtIndex:0];
    NSString* moduleTitle = [command.arguments objectAtIndex:1];

    MainViewController *viewController = [[ViewController alloc] init];

    if ([moduleName hasPrefix:@"http:"] || [moduleName hasPrefix:@"https:"]) {
        viewController.startPage = moduleName;
        [[UINavigationBar appearance] setTranslucent:NO];
    } else {
        viewController.startPage = [moduleName stringByAppendingString:@".html"];
        [[UINavigationBar appearance] setTranslucent:YES];
    }

//    viewController.configFile = [moduleName stringByAppendingString:@".xml"];
    viewController.configFile = @"www/index.xml";

    viewController.title = moduleTitle;
    UIColor *titleColor = [UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:1];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: titleColor
                                                           }];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
    [viewController.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    if (self.viewController.navigationController == NULL) {
        UINavigationController *nav = [[UINavigationController alloc] init];

        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:25.0 / 255.0 green:35.0 / 255.0 blue:60.0 / 255.0 alpha:1]];
//        [[UINavigationBar appearance] setTranslucent:NO];

        self.webView.window.rootViewController = nav;
        [nav pushViewController:self.viewController animated:false];
    }

    [self.viewController.navigationController pushViewController:viewController animated:true];
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
    [self.viewController.navigationController setNavigationBarHidden:YES animated:NO];
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

    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (self.inViewControllerStack) {
        [[UINavigationBar appearance] setTranslucent:NO];
        if ([self.startPage hasPrefix:@"http:"] || [self.startPage hasPrefix:@"https:"]) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }

        return;
    }

    CGRect viewBounds = self.view.bounds;

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"process.gif" ofType:nil];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];

    SCGIFImageView* gifImageView = [[SCGIFImageView alloc] initWithFrame:CGRectMake((viewBounds.size.width - 60) / 2, (viewBounds.size.height - 60) / 2, 60, 60)];
    [gifImageView setData:imageData];
    [self.view addSubview:gifImageView];

    self.loadingImageView = gifImageView;

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.inViewControllerStack = true;
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    NSLog(@"webViewDidFinishLoad");

    [self.loadingImageView removeFromSuperview];

    if ([self.startPage hasPrefix:@"http:"] || [self.startPage hasPrefix:@"https:"]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

    CDVViewController* vc = (CDVViewController*)self;

    // It's safe to release the lock even if this is just a sub-frame that's finished loading.
    [CDVUserAgentUtil releaseLock:vc.userAgentLockToken];

    /*
     * Hide the Top Activity THROBBER in the Battery Bar
     */
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPageDidLoadNotification object:self.webView]];
}

@end

