//
//  AppDelegate.h
//  m4399LoginExample
//
//  Created by 郑旭 on 16/7/27.
//  Copyright © 2016年 4399 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//TODO:请在运行DEMO前，填入应用相关配置信息

#define APP_CLIENT_ID @"此处填入4399用户中心分配的统一登录ClientID"
#define APP_CALLBACK_URL @"此处填入在4399用户中心配置的回调地址，通常为接入方自己的域名地址下的一个用于接收回调信息的url。注意保证前缀为http://或者https://"
#define URL_SCHEMES @"此处填入接入应用自身的UrlSchemes，配置方式参考开发文档"

//本Demo将部分接入方服务端接口在Demo客户端实现，所以将ClientSecret配置在此，强烈建议不要将ClientSecret记录在客户端，应将该值保存至服务端，由服务端完成 ViewController.m 中 -analysisRefreshToken & -analysisCode 中的网络请求，并将结果返回给客户端。
#define APP_CLIENT_SECRET @"此处填入4399用户中心分配的统一登录ClientSecret"







@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

