//
//  M4399LoginManager.h
//  M4399Login
//
//  Created by 郑旭 on 16/7/28.
//  Copyright © 2016年 4399 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface M4399LoginManagerConfig : NSObject

/**
 *  4399用户中心提供的Oauth2 ClientID
 */
@property(nonatomic, strong, nullable) NSString* clientId;
@property(nonatomic, strong, nullable) NSString* callbackUrl;
@property(nonatomic, strong, nullable) NSString* urlSchemes;




@end

typedef void (^M4399LoginRegisterBlockHandle) (BOOL isUserCancel, NSString* __nullable code, NSString* __nullable errorMsg);
typedef void (^M4399ModifyNicknameBlockHandle) (BOOL isSuccess, NSString* __nullable newNickname, NSString* __nullable errorMsg);
@interface M4399LoginManager : NSObject



+ (nonnull instancetype)shareManager;
- (nonnull instancetype)initWithConfig:(nullable M4399LoginManagerConfig *) config;
- (void)login:(M4399LoginRegisterBlockHandle __nullable) handler;
- (void)register:(M4399LoginRegisterBlockHandle __nullable) handler;
- (void)modifyNicknameWithUid:(nonnull NSString *)uid accessToken:(nonnull NSString *)accessToken handler:(M4399ModifyNicknameBlockHandle __nullable)handler;

- (void)handleOpenURL:(nonnull NSURL *)url;

@end


