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
#import "MainViewController.h"
#import "SCGIFImageView.h"

#ifdef __CORDOVA_4_0_0
#import <Cordova/CDVUIWebViewDelegate.h>
#else
#import <Cordova/CDVWebViewDelegate.h>
#endif

@interface Multiview : CDVPlugin

- (void)pushView:(CDVInvokedUrlCommand*)command;

- (void)popView:(CDVInvokedUrlCommand*)command;

- (void)popView;

- (void)hideNavigationBar:(CDVInvokedUrlCommand*)command;

@end

@interface ViewController : MainViewController<CDVScreenOrientationDelegate> {
#ifdef __CORDOVA_4_0_0
    CDVUIWebViewDelegate* _webViewDelegate;
#else
    CDVWebViewDelegate* _webViewDelegate;
#endif
}

@property (nonatomic, assign) BOOL inViewControllerStack;
@property (nonatomic, weak) SCGIFImageView* loadingImageView;
@property (nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;

@end
