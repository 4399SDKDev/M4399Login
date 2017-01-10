//
//  M4399LoginManager.h
//  M4399Login
//
//  Created by 郑旭 on 16/7/28.
//  Copyright © 2016年 4399 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#pragma mark - BLOCK
/**
 *  登录/注册 回调Block
 *
 *  @param isUserCancel 用户是否取消登录/注册
 *  @param code         WEB登录授权CODE
 *  @param refreshToken 游戏盒登录授权RefreshToken
 *  @param errorMsg     错误信息
 */
typedef void (^M4399LoginRegisterBlockHandle) (BOOL isUserCancel, NSString* __nullable code,NSString* __nullable refreshToken, NSString* __nullable errorMsg);


/**
 *  修改用户信息回调Block
 *
 *  @param isSuccess 是否有信息被修改
 *  @param errorMsg  错误信息
 */
typedef void (^M4399ModifyUserInfoBlockHandle) (BOOL isSuccess, NSString* __nullable errorMsg);




#pragma mark - M4399LoginManagerConfig
@interface M4399LoginManagerConfig : NSObject

#pragma mark 必填字段
/**
 *  4399用户中心提供的Oauth2 ClientID
 */
@property(nonatomic, strong, nullable) NSString* clientId;
/**
 *  配置在4399用户中心的回调地址
 */
@property(nonatomic, strong, nullable) NSString* callbackUrl;
/**
 *  APP为登录授权配置的UrlSchemes
 */
@property(nonatomic, strong, nullable) NSString* urlSchemes;

#pragma mark  UI配置
/**
 *  Loading画面颜色
 */
@property(nonatomic, strong, nullable) UIColor* hudColor;
/**
 *  导航栏背景色
 */
@property(nonatomic, strong, nullable) UIColor* navBackgroupColor;
/**
 *  导航按钮默认颜色
 */
@property(nonatomic, strong, nullable) UIColor* navButtonColor;
/**
 *  导航栏按钮高亮颜色
 */
@property(nonatomic, strong, nullable) UIColor* navButtonHighlightColor;

/**
 *  初始化Config填入必须字段
 *
 *  @param clientId    4399用户中心分配的ClientID
 *  @param callbackUrl 配置在4399用户中心的回调地址
 *  @param urlScheme   APP为登录授权配置的UrlSchemes
 *
 *  @return 配置实例
 */
- (nonnull instancetype)initWithClientId:(nonnull NSString *)clientId callbackUrl:(nonnull NSString *)callbackUrl urlScheme:(nonnull NSString *)urlScheme;


@end







#pragma mark - M4399LoginManager

@interface M4399LoginManager : NSObject


/**
 *  获取Manager单例
 *
 *  @return Manager单例
 */
+ (nonnull instancetype)shareManager;
/**
 *  获取SDK版本号
 *
 *  @return 版本号 例如『1.0.0』
 */
+ (nonnull NSString *)version;
/**
 *  初始化Manager
 *
 *  @param config 配置实例
 *
 *  @return Manager
 */
- (nonnull instancetype)initWithConfig:(nullable M4399LoginManagerConfig *) config;

/**
 *  登录
 *
 *  @param handler 登录回调Block
 */
- (void)login:(M4399LoginRegisterBlockHandle __nullable) handler;

/**
 *  注册
 *
 *  @param handler 注册回调Block
 */
- (void)register:(M4399LoginRegisterBlockHandle __nullable) handler;

/**
 *  修改用户信息
 *
 *  @param uid         用户ID
 *  @param accessToken 登录时返回的AccessToken
 *  @param handler     修改用户信息回调Block
 */
- (void)modifyUserInfoWithUid:(nonnull NSString *)uid accessToken:(nonnull NSString *)accessToken handler:(M4399ModifyUserInfoBlockHandle __nullable)handler;

/**
 *  UrlSchemes回调监听
 *
 *
 *  @param url AppDelegate中回调handelOpenURL:函数中回传的url参数
 */
- (void)handleOpenURL:(nonnull NSURL *)url;

@end


